exports.created = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  
  (data) ->
    Game.findByIdAndSetup data.gameId, data.characters, (err, game) ->
      return console.error err if err
      
      for id, conn of io.of("/").connected when game.name in conn.rooms
        currentPlayer = conn.request.session.user
        for player in game.players when player.name is currentPlayer
          conn.emit "set_player",
            currentPlayer: player
            knownPlayers: game.playersKnownTo player
          break
      
      socket.emit "show_player", game
      socket.broadcast.to(game.name).emit "stop_waiting_on_game_start", game

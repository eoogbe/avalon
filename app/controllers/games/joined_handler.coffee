module.exports = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  
  (data) ->
    Game.findOneAndDiscontinue data.playerId, (err, oldGame) ->
      return console.error err if err
      
      if oldGame
        socket.broadcast.to(oldGame.name).emit "warn_game_discontinued"
        
        for id, conn of io.of("/").connected when oldGame.name in conn.rooms
          conn.leave oldGame.name
      
      Game.findByIdAndAddPlayer data.gameId, data.playerId
        .populate "creator players"
        .exec (err, game) ->
          return console.error err if err
          
          socket.join game.name
          io.to(game.name).emit "show_players", game

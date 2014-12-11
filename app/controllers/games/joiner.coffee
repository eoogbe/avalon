module.exports = (eventCtx, models) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  player = models.player
  game = models.game
  
  Game.findOneAndUpdate { players: player, state: "playing" },
    { state: "discontinued" }, (err, oldGame) ->
      return console.error err if err
      
      if oldGame
        socket.broadcast.to(oldGame.name).emit "warn_game_discontinued"
        
        for id, conn of io.of("/").connected when oldGame.name in conn.rooms
          conn.leave oldGame.name
      
      game.addPlayer player, (err, game) ->
        return console.error err if err
        
        populatedFields = [{ path: "creator" }, { path: "players" }]
        Game.populate game, populatedFields, (err, game) ->
          return console.error err if err
          
          socket.join game.name
          
          io.to(game.name).emit "show_players",
            currentGame: game
            canStartGame: game.canStart()

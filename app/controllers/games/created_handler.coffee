module.exports = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  Rules = eventCtx.models.Rules
  
  (data) ->
    gameParams =
      name: data.name
      creator: data.playerId
      players: [data.playerId]
    
    Game.create gameParams, (err, game) ->
      if not err
        Game.findOneAndDiscontinue data.playerId, (err, oldGame) ->
          return console.error err if err
          
          if oldGame
            socket.broadcast.to(oldGame.name).emit "warn_game_discontinued"
            
            for id, conn of io.of("/").connected when oldGame.name in conn.rooms
              conn.leave oldGame.name
          
          populatedFields = [{ path: "creator" }, { path: "players" }]
          Game.populate game, populatedFields, (err, game) ->
            return console.error err if err
            
            socket.join game.name
            
            characterStats = Rules.getCharacterStats data.numPlayers
            
            socket.emit "show_new_characters",
              currentGame: game
              characterStats: characterStats
      else if err.name is "ValidationError"
        socket.emit "new_game_error", err.errors
      else
        console.error err

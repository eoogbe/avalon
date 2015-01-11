module.exports = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  Rules = eventCtx.models.Rules
  
  (data) ->
    Game.create { name: data.name }, (err, game) ->
      if not err
        Player.upsert { game: game, user: data.userId }, (err, player) ->
          throw err if err
          
          game.creator = player
          game.players.push player
          game.save (err, game) ->
            throw err if err
            
            Game.findOneAndDiscontinue data.userId, (err, oldGame) ->
              throw err if err
              
              if oldGame
                socket.broadcast.to(oldGame.name).emit "warn_game_discontinued"
                
                for id, conn of io.of("/").connected when oldGame.name in conn.rooms
                  conn.leave oldGame.name
              
              Game.populate game, { path: "creator" }, (err, game) ->
                throw err if err
                
                Player.findGamePlayers game, (err, gamePlayers) ->
                  throw err if err
                  
                  socket.join game.name
                  socket.emit "show_new_characters",
                    currentPlayer: player
                    currentGame: game
                    gamePlayers: gamePlayers
                    characterStats: Rules.getCharacterStats data.numPlayers
      else if err.name is "ValidationError"
        socket.emit "new_game_error", err.errors
      else
        throw err

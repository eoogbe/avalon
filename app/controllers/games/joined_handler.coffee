module.exports = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  Rules = eventCtx.models.Rules
  
  (data) ->
    Player.upsert { game: data.gameId, user: data.userId }, (err, player) ->
      throw err if err
      
      Game.findByIdAndAddPlayer data.gameId, player
        .populate "creator players"
        .exec (err, game) ->
          throw err if err
          
          socket.join game.name
          
          Game.findOneAndDiscontinue data.userId, (err, oldGame) ->
            throw err if err
            
            if oldGame
              socket.broadcast.to(oldGame.name).emit "warn_game_discontinued"
              
              for id, conn of io.of("/").connected when oldGame.name in conn.rooms
                conn.leave oldGame.name
              
            unless game.characters.length is game.players.length
              Player.findGamePlayers game, (err, gamePlayers) ->
                throw err if err
                
                socket.emit "set_player", player
                io.to(game.name).emit "show_players",
                  currentGame: game
                  gamePlayers: gamePlayers
            else
              game.start (err) ->
                throw err if err
                
                Player.findGamePlayers game, (err, gamePlayers) ->
                  throw err if err
                  
                  characterStats = Rules.getCharacterStats gamePlayers.length
                  
                  for id, conn of io.of("/").connected when game.name in conn.rooms
                    userId = conn.request.session.user
                    for player in gamePlayers when player.user._id.equals userId
                      conn.emit "show_player",
                        currentPlayer: player
                        currentGame: game
                        knownPlayers: Rules.getPlayersKnown player, gamePlayers
                        characterStats: characterStats

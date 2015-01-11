exports.updated = (eventCtx) ->
  socket = eventCtx.socket
  session = socket.request.session
  User = eventCtx.models.User
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  showGames = eventCtx.showGames
  
  (name) ->
    User.upsert { name: name }, (err, user) ->
      if not err
        session.user = user._id
        session.save (err) ->
          throw err if err
          
          Player.findCurrent user, (err, player) ->
            throw err if err
            
            if player
              Game.findById player.game, (err, game) ->
                throw err if err
                
                Player.findGamePlayers game, (err, gamePlayers) ->
                  throw err if err
                  
                  showGames
                    currentUser: user
                    currentPlayer: player
                    currentGame: game
                    gamePlayers: gamePlayers
            else
              showGames currentUser: user
      else if err.name is "ValidationError"
        socket.emit "edit_user_error", err.errors
      else
        throw err

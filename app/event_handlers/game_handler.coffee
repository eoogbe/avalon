exports.created = (io, models) ->
  (data) ->
    models.Game.create { name: data.name }, (err, game) ->
      if !err
        models.Player.findById data.playerId, (err, player) ->
          return console.error err if err
          
          player.join game, (err, game) ->
            return console.error err if err
            
            io.emit "show_new_quest", game
      else if err.name is "ValidationError"
        io.emit "new_game_error", err.errors
      else
        console.error err

exports.joined = (io, models) ->
  (data) ->
    models.Player.findById data.playerId, (err, player) ->
      return console.error err if err
      
      models.Game.findById data.gameId, (err, game) ->
        return console.error err if err
        
        player.join game, (err, game) ->
          return console.error err if err
          
          io.emit "show_new_quest", game

exports.gameover = (io, models, showGames) ->
  -> showGames()

exports.updated = (io, models, showGames) ->
  (name) ->
    models.Player.findOne { name: name }, (err, player) ->
      return console.error err if err
      
      if player
        showGames(player)
      else
        models.Player.create { name: name }, (err, player) ->
          if !err
            showGames(player)
          else if err.name is "ValidationError"
            io.emit "new_player_error", err.errors
          else
            console.error err

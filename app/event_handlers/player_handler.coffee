exports.updated = (eventCtx, showGames) ->
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  
  (name) ->
    Player.findOneAndUpdate({ name: name }, {}, { upsert: true }).lean().exec (err, player) ->
      if !err
        showGames(player)
      else if err.name is "ValidationError"
        socket.emit "new_player_error", err.errors
      else
        console.error err

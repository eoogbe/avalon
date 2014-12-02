exports.updated = (eventCtx) ->
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  showGames = eventCtx.showGames
  
  (name) ->
    Player.findOneAndUpdate({ name: name }, {}, { upsert: true }).lean().exec (err, player) ->
      if !err
        showGames(player)
      else if err.name is "ValidationError"
        socket.emit "edit_player_error", err.errors
      else
        console.error err

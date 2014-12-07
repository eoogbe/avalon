exports.updated = (eventCtx) ->
  socket = eventCtx.socket
  session = socket.request.session
  Player = eventCtx.models.Player
  showGames = eventCtx.showGames
  
  (name) ->
    Player.upsert { name: name }, (err, player) ->
      if not err
        session.user = name
        session.save (err) ->
          return console.error err if err
          
          showGames(player)
      else if err.name is "ValidationError"
        socket.emit "edit_player_error", err.errors
      else
        console.error err

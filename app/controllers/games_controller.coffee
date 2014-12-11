reqHandler = (handlerName) ->
  require "./games/#{handlerName}_handler"

[createdHandler, joinedHandler, leftHandler, startedHandler, deletedHandler, continuedHandler, merlinSelectedHandler] =
  (reqHandler h for h in ["created", "joined", "left", "started", "deleted", "continued", "merlin_selected"])

exports.created = (eventCtx) ->
  createdHandler eventCtx

exports.joined = (eventCtx) ->
  joinedHandler eventCtx

exports.left = (eventCtx) ->
  leftHandler eventCtx

exports.started = (eventCtx) ->
  startedHandler eventCtx

exports.deleted = (eventCtx) ->
  deletedHandler eventCtx

exports.continued = (eventCtx) ->
  continuedHandler eventCtx

exports.merlinSelected = (eventCtx) ->
  merlinSelectedHandler eventCtx

exports.reloaded = (eventCtx) ->
  showGames = eventCtx.showGames
  
  (gameName) ->
    for id, conn of io.of("/").connected when gameName in conn.rooms
      conn.leave gameName
    
    showGames()

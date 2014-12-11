reqHandler = (handlerName) ->
  require "./games/#{handlerName}_handler"

[createdHandler, joinedHandler, leftHandler, startedHandler, deletedHandler, continuedHandler] =
  (reqHandler h for h in ["created", "joined", "left", "started", "deleted", "continued"])

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

exports.reloaded = (eventCtx) ->
  eventCtx.showGames

models = require "./models"

reqEventHandler = (handlerName) ->
  require "../app/event_handlers/#{handlerName}_handler"

playersHandler = reqEventHandler "players"
gamesHandler = reqEventHandler "games"
questsHandler = reqEventHandler "quests"
questOutcomesHandler = reqEventHandler "quest_outcomes"

module.exports = (io, sessionMiddleware) ->
  io.use (socket, next) ->
    sessionMiddleware socket.request, socket.request.res, next
  
  io.on "connection", (socket) ->
    session = socket.request.session
    
    socket.on "disconnect", ->
      session.destroy()
    
    eventCtx =
      io: io
      socket: socket
      session: session
      models: models
      showGames: (player) ->
        models.Game.unstarted (err, games) ->
          return console.error err if err
          
          socket.emit "show_games",
            games: games
            currentPlayer: player
    
    socket.emit "show_edit_player"
    
    socket.on "player_updated", playersHandler.updated(eventCtx)
    socket.on "game_created", gamesHandler.created(eventCtx)
    socket.on "game_joined", gamesHandler.joined(eventCtx)
    socket.on "game_left", gamesHandler.left(eventCtx)
    socket.on "game_started", gamesHandler.started(eventCtx)
    socket.on "game_deleted", gamesHandler.deleted(eventCtx)
    socket.on "game_reloaded", gamesHandler.reloaded(eventCtx)
    socket.on "quest_updated", questsHandler.updated(eventCtx)
    socket.on "quest_outcome_created", questOutcomesHandler.created(eventCtx)

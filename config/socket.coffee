reqController = (controllerName) ->
  require "../app/controllers/#{controllerName}_controller"

playersController = reqController "players"
gamesController = reqController "games"
questsController = reqController "quests"
questOutcomesController = reqController "quest_outcomes"
questorsController = reqController "questors"

module.exports = (io, sessionMiddleware, models) ->
  io.use (socket, next) ->
    sessionMiddleware socket.request, socket.request.res, next
  
  io.on "connection", (socket) ->
    session = socket.request.session
    
    socket.on "disconnect", ->
      session.destroy()
    
    eventCtx =
      io: io
      socket: socket
      models: models
      showGames: (data) ->
        models.Game.unstarted().lean().exec (err, games) ->
          return console.error err if err
          
          data ?= {}
          data.games = games
          
          socket.emit "show_games", data
    
    socket.emit "show_edit_player"
    
    socket.on "player_updated", playersController.updated(eventCtx)
    socket.on "game_created", gamesController.created(eventCtx)
    socket.on "game_joined", gamesController.joined(eventCtx)
    socket.on "game_left", gamesController.left(eventCtx)
    socket.on "game_continued", gamesController.continued(eventCtx)
    socket.on "game_started", gamesController.started(eventCtx)
    socket.on "game_deleted", gamesController.deleted(eventCtx)
    socket.on "game_reloaded", gamesController.reloaded(eventCtx)
    socket.on "quest_updated", questsController.updated(eventCtx)
    socket.on "quest_voted_on", questsController.votedOn(eventCtx)
    socket.on "quest_started", questsController.started(eventCtx)
    socket.on "quest_outcome_created", questOutcomesController.created(eventCtx)
    socket.on "questors_created", questorsController.created(eventCtx)
    socket.on "questors_deleted", questorsController.deleted(eventCtx)

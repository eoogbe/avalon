reqController = (controllerName) ->
  require "../app/controllers/#{controllerName}_controller"

[usersController, charactersController, gamesController, questsController, questOutcomesController, questorsController] =
  (reqController c for c in ["users", "characters", "games", "quests", "quest_outcomes", "questors"])

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
        models.Game.findUnstarted().lean().exec (err, games) ->
          return console.error err if err
          
          data ?= {}
          data.games = games
          
          socket.emit "show_games", data
    
    socket.emit "show_edit_user"
    
    socket.on "user_updated", usersController.updated(eventCtx)
    socket.on "characters_created", charactersController.created(eventCtx)
    socket.on "game_created", gamesController.created(eventCtx)
    socket.on "game_joined", gamesController.joined(eventCtx)
    socket.on "game_left", gamesController.left(eventCtx)
    socket.on "game_continued", gamesController.continued(eventCtx)
    socket.on "game_deleted", gamesController.deleted(eventCtx)
    socket.on "game_reloaded", gamesController.reloaded(eventCtx)
    socket.on "merlin_selected", gamesController.merlinSelected(eventCtx)
    socket.on "quest_updated", questsController.updated(eventCtx)
    socket.on "quest_voted_on", questsController.votedOn(eventCtx)
    socket.on "quest_started", questsController.started(eventCtx)
    socket.on "quest_outcome_created", questOutcomesController.created(eventCtx)
    socket.on "questors_created", questorsController.created(eventCtx)
    socket.on "questors_deleted", questorsController.deleted(eventCtx)

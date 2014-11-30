@Avalon = (socket) ->
  self = this
  
  self.currentPage = ko.observable()
  self.currentGame = ko.observable({})
  self.currentQuest = ko.observable()
  self.gameError = ko.observable()
  self.questStats = ko.observable()
  self.games = ko.observableArray()
  
  self.hasGameError = ko.computed((->
    self.gameError()?
  ), self)
  
  self.winnerType = ko.computed((->
    if self.currentGame().state is "good_won"
      "Good"
    else if self.currentGame().state is "bad_won"
      "Bad"
  ), self)
  
  self.isCurrentPage = (pageName) ->
    self.currentPage() is pageName
  
  self.goToNewGame = ->
    self.gameError null
    self.currentPage "new_game"
  
  self.goToGames = ->
    self.currentPage "games"
  
  self.createGame = ->
    name = $('input[name="game-name"]').val()
    socket.emit "game_created", name
  
  self.joinGame = (id) ->
    socket.emit "game_joined", id
  
  createOutcome = (state) ->
    socket.emit "quest_created",
      state: state
      gameId: self.currentGame()._id
  
  self.createSuccessOutcome = ->
    createOutcome "succeeded"
  
  self.createFailOutcome = ->
    createOutcome "failed"
  
  self.nextQuest = ->
    self.currentPage "new_quest"
  
  self.playAgain = ->
    self.currentPage "games"
  
  self

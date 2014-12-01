@Avalon = (socket) ->
  self = this
  
  self.currentPage = ko.observable()
  self.currentGame = ko.observable({})
  self.currentPlayer = ko.observable()
  self.currentQuest = ko.observable()
  self.gameError = ko.observable()
  self.playerError = ko.observable()
  self.questStats = ko.observable()
  self.waitingDialogMsg = ko.observable()
  self.games = ko.observableArray()
  
  self.hasGameError = ko.computed((->
    self.gameError()?
  ), self)
  
  self.hasPlayerError = ko.computed((->
    self.playerError()?
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
    $("#game-name").focus()
  
  self.goToGames = ->
    self.currentPage "games"
  
  inputVal = (model, attr) ->
    $("input[name='#{model}-#{attr}']").val()
  
  self.updatePlayer = ->
    name = inputVal "player", "name"
    socket.emit "player_updated", name
  
  self.createGame = ->
    name = inputVal "game", "name"
    socket.emit "game_created",
      name: name
      playerId: self.currentPlayer()._id
  
  self.joinGame = (gameId) ->
    socket.emit "game_joined",
      gameId: gameId
      playerId: self.currentPlayer()._id
  
  createOutcome = (isSuccess) ->
    socket.emit "quest_outcome_created",
      outcome: isSuccess
      questId: self.currentQuest()._id
  
  self.createSuccessOutcome = ->
    createOutcome true
  
  self.createFailOutcome = ->
    createOutcome false
  
  self.updateQuest = ->
    socket.emit "quest_updated", self.currentGame()._id
  
  self.playAgain = ->
    socket.emit "gameover"
  
  self

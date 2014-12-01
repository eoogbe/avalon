@Avalon = (socket) ->
  self = this
  
  self.currentPage = ko.observable("edit_player")
  self.currentGame = ko.observable({})
  self.currentPlayer = ko.observable()
  self.currentQuest = ko.observable()
  self.gameError = ko.observable()
  self.playerError = ko.observable()
  self.questStats = ko.observable()
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
  
  self.goToGames = ->
    self.currentPage "games"
  
  self.goToNewQuest = ->
    self.currentPage "new_quest"
  
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
  
  createOutcome = (state) ->
    socket.emit "quest_created",
      state: state
      gameId: self.currentGame()._id
  
  self.createSuccessOutcome = ->
    createOutcome "succeeded"
  
  self.createFailOutcome = ->
    createOutcome "failed"
  
  self.playAgain = ->
    socket.emit "gameover"
  
  self

@Avalon ?= {}
Avalon.Player = (socket, root) ->
  NUM_GOOD_IMGS = 5
  NUM_BAD_IMGS = 3
  
  self = this
  
  self.current = ko.observable({})
  self.error = ko.observable()
  self.knownPlayers = ko.observableArray()
  
  self.currentId = ko.pureComputed((-> self.current()._id ), self)
  
  self.character = ko.pureComputed((->
    self.characterFor self.current().character
  ), self)
  
  self.hasError = ko.pureComputed((->
    self.error()? and not $.isEmptyObject self.error()
  ), self)
  
  self.knowsPlayers = ko.pureComputed((->
    self.knownPlayers().length > 0
  ), self)
  
  self.isGameCreator = ko.pureComputed((->
    root.game().creatorName() is self.current().name
  ), self)
  
  self.isGood = ko.pureComputed((->
    self.current().character is "Good"
  ), self)
  
  self.isQuestor = ko.pureComputed((->
    root.quest().isPlaying() and root.quest().hasQuestor self.current()
  ), self)
  
  self.characterImg = ->
    if self.current().character is "Good"
      num = Math.floor Math.random() * NUM_GOOD_IMGS + 1
      "/images/good#{num}_small.jpg"
    else if self.current().character is "Bad"
      num = Math.floor Math.random() * NUM_BAD_IMGS + 1
      "/images/bad#{num}_small.jpg"
  
  self.characterFor = (character) ->
    if character is "Good"
      "a Loyal Servant of Arthur"
    else if character is "Bad"
      "a Minon of Mordred"
  
  self.update = ->
    name = $("#player-name").val()
    socket.emit "player_updated", name
  
  self.confirmJoinGame = (gameId) ->
    return self.joinGame gameId unless root.game().isPlaying()
    
    root.confirmDialog
      type: "panel-danger"
      message: "You have a game in progress. The game will be discontinued for all players. Continue?"
      action: -> self.joinGame gameId
      positiveBtnText: "Yes, join a new game"
      negativeBtnText: "No, go back to the old game"
      negativeBtnAction: root.game().continue
    $("#confirm-dialog").modal "show"
  
  self.joinGame = (gameId) ->
    $("#confirm-dialog").modal "hide"
    socket.emit "game_joined",
      gameId: gameId
      playerId: self.currentId()
  
  self.leaveGame = ->
    root.alert null
    socket.emit "game_left",
      gameId: root.game().currentId()
      playerId: self.currentId()
  
  self

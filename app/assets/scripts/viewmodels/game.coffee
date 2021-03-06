@Avalon ?= {}
Avalon.Game = (socket, root) ->
  STATS_STATES = ["playing", "assassinating", "good_won", "bad_won"]
  self = this
  
  self.current = ko.observable({})
  self.error = ko.observable()
  self.players = ko.observableArray()
  self.list = ko.observableArray()
  
  self.currentId = ko.pureComputed((-> self.current()._id ), self)
  
  self.hasCurrent = ko.pureComputed((->
    self.current()? and not $.isEmptyObject self.current()
  ), self)
  
  self.hasError = ko.pureComputed((->
    self.error()? and not $.isEmptyObject self.error()
  ), self)
  
  self.hasGames = ko.pureComputed((->
    self.list().length > 0
  ), self)
  
  self.isPlaying = ko.pureComputed((->
    self.current().state is "playing"
  ), self)
  
  self.isInGame = ko.pureComputed((->
    self.current().state in ["playing", "assassinating"]
  ), self)
  
  self.isOver = ko.pureComputed((->
    self.current().state in ["good_won", "bad_won"]
  ), self)
  
  self.shouldShowStats = ko.pureComputed((->
    self.current()? and self.current().state in STATS_STATES and
      not (root.nav().currentPage() in ["new_game", "games"])
  ), self)
  
  self.creatorId = ko.pureComputed((->
    if self.hasCurrent() then self.current().creator._id else null
  ), self)
  
  self.numPlayers = ko.pureComputed((->
    self.players().length
  ), self)
  
  self.nonquestors = ko.pureComputed((->
    _.reject self.players(), root.quest().hasQuestor
  ), self)
  
  self.numRejectedQuests = ko.pureComputed((->
    self.current().numRejectedQuests
  ), self)
  
  self.winnerType = ko.pureComputed((->
    if self.current().state is "good_won"
      "Good"
    else if self.current().state is "bad_won"
      "Bad"
  ), self)
  
  self.confirmCreate = ->
    return self.create() unless self.isInGame()
    
    root.confirmDialog
      type: "panel-danger"
      message: "You have a game in progress. The game will be discontinued for all players. Continue?"
      action: self.create
      positiveBtnText: "Yes, create a new game"
      negativeBtnText: "No, go back to the old game"
      negativeBtnAction: self.continue
    $("#confirm-dialog").modal "show"
  
  self.create = ->
    $("#confirm-dialog").modal "hide"
    socket.emit "game_created",
      name: $("#game-name").val()
      numPlayers: $("#game-num-players").val()
      userId: root.user().currentId()
  
  self.confirmDelete = ->
    root.confirmDialog
      type: "panel-danger"
      message: "This cannot be undone. The other players will be booted out of the game. Continue?"
      action: self.delete_
      positiveBtnText: "Yes, delete this game"
      negativeBtnText: "No, keep the game"
    $("#confirm-dialog").modal "show"
  
  self.delete_ = ->
    $("#confirm-dialog").modal "hide"
    socket.emit "game_deleted", self.currentId()
  
  self.continue = ->
    $("#confirm-dialog").modal "hide"
    socket.emit "game_continued",
      playerId: root.player().currentId()
      gameId: self.currentId()
  
  self.killMerlin = ->
    socket.emit "merlin_selected",
      gameId: self.currentId()
      merlinId: $("#good-characters").val()
  
  self.reload = ->
    $("#action-dialog").modal "hide"
    root.alert null
    
    self.players.removeAll()
    root.quest().reset()
    
    socket.emit "game_reloaded", self.current().name
  
  self

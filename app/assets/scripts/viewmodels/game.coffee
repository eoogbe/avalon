@Avalon ?= {}
Avalon.Game = (socket, root) ->
  self = this
  
  self.current = ko.observable({})
  self.error = ko.observable()
  self.canStart = ko.observable()
  self.list = ko.observableArray()
  
  self.hasCurrent = ko.pureComputed((->
    self.current()? and not $.isEmptyObject self.current()
  ), self)
  
  self.hasError = ko.pureComputed((->
    self.error()? and not $.isEmptyObject self.error()
  ), self)
  
  self.currentId = ko.pureComputed((-> self.current()._id ), self)
  
  self.creatorName = ko.pureComputed((->
    if self.hasCurrent() then self.current().creator.name else null
  ), self)
  
  self.nonquestors = ko.pureComputed((->
    _.reject self.current().players, root.quest().hasQuestor
  ), self)
  
  self.winnerType = ko.pureComputed((->
    if self.current().state is "good_won"
      "Good"
    else if self.current().state is "bad_won"
      "Bad"
  ), self)
  
  self.create = ->
    name = root.inputVal "game", "name"
    socket.emit "game_created",
      name: name
      playerId: root.player().currentId()
  
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
  
  self.confirmStart = ->
    root.confirmDialog
      type: "panel-primary"
      message: "No additional players will be able to join the game. Continue?"
      action: self.start
      positiveBtnText: "Yes, let's start"
      negativeBtnText: "No, wait for more players"
    $("#confirm-dialog").modal "show"
  
  self.start = ->
    $("#confirm-dialog").modal "hide"
    socket.emit "game_started", self.currentId()
  
  self.reload = ->
    $("#warning-dialog").modal "hide"
    root.alert null
    socket.emit "game_reloaded"
  
  self

@Avalon ?= {}
Avalon.Quest = (socket, root) ->
  self = this
  
  self.current = ko.observable()
  self.stats = ko.observable()
  
  self.kingName = ko.pureComputed((->
    self.current()?.king?.name
  ), self)
  
  self.hasEnoughQuestors = ko.pureComputed((->
    self.current()?.players?.length >= 2
  ), self)
  
  createOutcome = (isSuccess) ->
    socket.emit "quest_outcome_created",
      outcome: isSuccess
      questId: self.current()._id
  
  self.hasQuestor = (player) ->
    _.any self.current().players, name: player.name
  
  self.createSuccessOutcome = ->
    createOutcome true
  
  self.createFailOutcome = ->
    createOutcome false
  
  self.nextKing = ->
    socket.emit "quest_updated",
      gameId: root.game().currentId()
      state: "unstarted"
  
  self.addQuestors = ->
    socket.emit "questors_created",
      questId: self.current()._id
      questorId: $("#nonquestors option:selected").val()
  
  self.removeQuestors = ->
    socket.emit "questors_deleted",
      questId: self.current()._id
      questorId: $("#questors option:selected").val()
  
  self.confirmStart = ->
    root.confirmDialog
      type: "panel-warning"
      message: "You will not be able to change your choices. Continue?"
      action: self.start
      positiveBtnText: "Yes, let's start"
      negativeBtnText: "No, go back"
    $("#confirm-dialog").modal "show"
  
  self.start = ->
    $("#confirm-dialog").modal "hide"
    socket.emit "quest_started", self.current()._id
  
  self.nextQuest = ->
    socket.emit "quest_updated",
      gameId: root.game().currentId()
      state: "playing"
  
  self

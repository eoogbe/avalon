@Avalon ?= {}
Avalon.Quest = (socket, root) ->
  self = this
  
  self.current = ko.observable({})
  self.error = ko.observable()
  self.king = ko.observable()
  self.isLastRejectableQuest = ko.observable()
  self.stats = ko.observable()
  self.players = ko.observableArray()
  
  self.currentId = ko.pureComputed((-> self.current()._id ), self)
  
  self.kingId = ko.pureComputed((->
    self.king()?._id
  ), self)
  
  self.kingName = ko.pureComputed((->
    if self.king()? then self.king().user.name else "none"
  ), self)
  
  self.numSucceeded = ko.pureComputed((->
    if self.stats()? then self.stats().numSucceeded else 0
  ), self)
  
  self.numFailed = ko.pureComputed((->
    if self.stats()? then self.stats().numFailed else 0
  ), self)
  
  self.hasCurrent = ko.pureComputed((->
    self.current()? and not $.isEmptyObject self.current()
  ), self)
  
  self.hasError = ko.pureComputed((->
    self.error()? and not $.isEmptyObject self.error()
  ), self)
  
  self.hasEnoughQuestors = ko.pureComputed((->
    self.players().length >= self.current().numPlayersNeeded
  ), self)
  
  self.isRejected = ko.pureComputed((->
    self.current().state is "rejected"
  ), self)
  
  self.isPlaying = ko.pureComputed((->
    self.current().state is "playing"
  ), self)
  
  self.needsTwoFails = ko.pureComputed((->
    self.current().numFailsRequired is 2
  ), self)
  
  self.hasKing = (player) ->
    _.isEqual self.kingId(), player._id
  
  self.hasQuestor = (player) ->
    _.any self.players(), (p) -> _.isEqual p._id, player._id
  
  self.reset = ->
    self.current {}
    self.king null
    self.stats null
    self.players.removeAll() 
    self.isLastRejectableQuest false
  
  self.update = ->
    $("#action-dialog").modal "hide"
    socket.emit "quest_updated", root.game().currentId()
  
  self.addQuestors = ->
    socket.emit "questors_created",
      questId: self.currentId()
      questorId: $("#nonquestors option:selected").val()
  
  self.removeQuestors = ->
    socket.emit "questors_deleted",
      questId: self.currentId()
      questorId: $("#questors option:selected").val()
  
  self.confirmStart = ->
    if not self.hasEnoughQuestors()
      additionalQuestorsNeeded =
        self.current().numPlayersNeeded - self.players().length
      pluralizePlayers = if additionalQuestorsNeeded is 1 then "player" else "players"
      self.error "You must select #{additionalQuestorsNeeded} more #{pluralizePlayers} to go on the quest. (You can select yourself.)"
    else if $("input[name='king-quest-vote']:checked").length is 0
      self.error "You must approve or reject your own quest"
    else
      root.confirmDialog
        type: "panel-warning"
        message: "You will not be able to change your choices. Continue?"
        action: self.start
        positiveBtnText: "Yes, let's start"
        negativeBtnText: "No, go back"
      $("#confirm-dialog").modal "show"
  
  self.start = ->
    self.error null
    $("#confirm-dialog").modal "hide"
    socket.emit "quest_started", self.currentId()
  
  self

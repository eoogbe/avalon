@Avalon ?= {}
Avalon.Quest = (socket, root) ->
  self = this
  
  self.current = ko.observable({})
  self.error = ko.observable()
  self.isLastRejectableQuest = ko.observable()
  self.stats = ko.observable()
  self.votes = ko.observableArray()
  
  self.currentId = ko.pureComputed((-> self.current()._id ), self)
  
  self.kingName = ko.pureComputed((->
    self.current().king?.name
  ), self)
  
  self.hasCurrent = ko.pureComputed((->
    self.current()? and not $.isEmptyObject self.current()
  ), self)
  
  self.hasError = ko.pureComputed((->
    self.error()? and not $.isEmptyObject self.error()
  ), self)
  
  self.hasEnoughQuestors = ko.pureComputed((->
    self.current().players?.length >= self.current().numPlayersNeeded
  ), self)
  
  self.isRejected = ko.pureComputed((->
    self.current().state is "rejected"
  ), self)
  
  self.isPlaying = ko.pureComputed((->
    self.current().state is "playing"
  ), self)
  
  self.hasApprovers = ko.pureComputed((->
    _.any self.votes(), "isApprove"
  ), self)
  
  self.hasRejectors = ko.pureComputed((->
    _.any self.votes(), isApprove: false
  ), self)
  
  self.voteResult = ko.pureComputed((->
    if self.isRejected() then "rejected" else "approved"
  ), self)
  
  self.approvers = ko.pureComputed((->
    _.map _.filter(self.votes(), "isApprove"), "player"
  ), self)
  
  self.rejectors = ko.pureComputed((->
    _.map _.reject(self.votes(), "isApprove"), "player"
  ), self)
  
  self.outcomes = ko.pureComputed((->
    self.current().outcomes?.sort()
  ), self)
  
  self.failOutcomeImg = ->
    if root.player().isGood() then "/images/fail_disabled.jpg" else "/images/fail.jpg"
  
  self.outcomeImgAttrs = (isSuccess) ->
    if isSuccess
      { src: "/images/success.jpg", alt: "Success" }
    else
      { src: "/images/fail.jpg", alt: "Fail" }
  
  self.isKing = (player) ->
    self.kingName() is player.name
  
  createOutcome = (isSuccess) ->
    socket.emit "quest_outcome_created",
      outcome: isSuccess
      questId: self.currentId()
  
  self.hasQuestor = (player) ->
    _.any self.current().players, name: player.name
  
  self.createSuccessOutcome = ->
    createOutcome true
  
  self.createFailOutcome = ->
    createOutcome false
  
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
        self.current().numPlayersNeeded - self.current().players.length
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

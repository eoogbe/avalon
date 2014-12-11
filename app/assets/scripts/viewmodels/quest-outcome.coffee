@Avalon ?= {}
Avalon.QuestOutcome = (socket, root) ->
  self = this
  
  self.list = ko.pureComputed((->
    _.shuffle(root.quest().current().outcomes ? [])
  ), self)
  
  self.failImg = ->
    if root.player().isGood() then "/images/fail_disabled.jpg" else "/images/fail.jpg"
  
  self.imgAttrs = (isSuccess) ->
    if isSuccess
      { src: "/images/success.jpg", alt: "Success" }
    else
      { src: "/images/fail.jpg", alt: "Fail" }
  
  create = (isSuccess) ->
    socket.emit "quest_outcome_created",
      outcome: isSuccess
      questId: root.quest().currentId()
  
  self.createSuccess = ->
    create true
  
  self.createFail = ->
    create false
  
  self

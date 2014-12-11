@Avalon ?= {}
Avalon.QuestVote = (socket, root) ->
  self = this
  
  self.list = ko.observableArray()
  
  self.needsAdditional = ko.pureComputed((->
    self.numNeeded() > 0
  ), self)
  
  self.hasApprovers = ko.pureComputed((->
    _.any self.list(), "isApprove"
  ), self)
  
  self.hasRejectors = ko.pureComputed((->
    _.any self.list(), isApprove: false
  ), self)
  
  self.numNeeded = ko.pureComputed((->
    root.game().currentPlayers().length - self.list().length
  ), self)
  
  self.pluralizeNumNeeded = ko.pureComputed((->
    if self.numNeeded() > 1 then "#{self.numNeeded()} people have" else "1 person has"
  ), self)
  
  self.result = ko.pureComputed((->
    if root.quest().isRejected() then "rejected" else "approved"
  ), self)
  
  self.approvers = ko.pureComputed((->
    _.map _.filter(self.list(), "isApprove"), "player"
  ), self)
  
  self.rejectors = ko.pureComputed((->
    _.map _.reject(self.list(), "isApprove"), "player"
  ), self)
  
  self.alertNeeded = ->
    if self.needsAdditional()
      root.alert
        type: "alert-warning"
        message: '<span
            id="num-voters-needed"
            data-bind="text: pluralizeNumNeeded"
          ></span> not yet voted'
      ko.applyBindings self, $("#num-voters-needed")[0]
    else
      root.alert null
  
  self

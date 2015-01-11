@Avalon ?= {}
Avalon.Player = (socket, root) ->
  self = this
  
  self.current = ko.observable({})
  self.knownPlayers = ko.observableArray()
  
  self.currentId = ko.pureComputed((-> self.current()._id ), self)
  
  self.vote = ko.pureComputed((->
    voteObj = _.find root.questVote().list(), (vote) ->
      _.isEqual vote.player._id, self.currentId()
    if voteObj.isApprove then "approve" else "reject"
  ), self)
  
  self.hasCurrent = ko.pureComputed((->
    self.current()? and not $.isEmptyObject self.current()
  ), self)
  
  self.knowsPlayers = ko.pureComputed((->
    self.knownPlayers().length > 0
  ), self)
  
  self.isGameCreator = ko.pureComputed((->
    _.isEqual root.game().creatorId(), self.currentId()
  ), self)
  
  self.isGood = ko.pureComputed((->
    root.character().isGood self.current()
  ), self)
  
  self.isKing = ko.pureComputed((->
    root.quest().hasKing self.current()
  ), self)
  
  self.hasVoted = ko.pureComputed((->
    _.any root.questVote().list(), (vote) ->
      _.isEqual vote.player._id, self.currentId()
  ), self)
  
  self.isQuestor = ko.pureComputed((->
    root.quest().isPlaying() and root.quest().hasQuestor self.current()
  ), self)
  
  self

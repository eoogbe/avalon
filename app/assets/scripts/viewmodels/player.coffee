@Avalon ?= {}
Avalon.Player = (socket, root) ->
  self = this
  
  self.current = ko.observable({})
  self.error = ko.observable()
  self.knownPlayers = ko.observableArray()
  
  self.currentId = ko.pureComputed((-> self.current()._id ), self)
  
  self.vote = ko.pureComputed((->
    voteObj = _.find root.questVote().list(), (vote) ->
      vote.player.name is self.current().name
    if voteObj.isApprove then "approve" else "reject"
  ), self)
  
  self.hasCurrent = ko.pureComputed((->
    self.current()? and not $.isEmptyObject self.current()
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
    root.character().isGood self.current()
  ), self)
  
  self.isKing = ko.pureComputed((->
    root.quest().hasKing self.current()
  ), self)
  
  self.hasVoted = ko.pureComputed((->
    _.any root.questVote().list(), (vote) ->
      vote.player.name is self.current().name
  ), self)
  
  self.isQuestor = ko.pureComputed((->
    root.quest().isPlaying() and root.quest().hasQuestor self.current()
  ), self)
  
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

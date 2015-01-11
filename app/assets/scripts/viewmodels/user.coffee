@Avalon ?= {}
Avalon.User = (socket, root) ->
  self = this
  
  self.current = ko.observable({})
  self.error = ko.observable()
  
  self.currentId = ko.pureComputed((-> self.current()._id ), self)
  
  self.hasCurrent = ko.pureComputed((->
    self.current()? and not $.isEmptyObject self.current()
  ), self)
  
  self.hasError = ko.pureComputed((->
    self.error()? and not $.isEmptyObject self.error()
  ), self)
  
  self.update = ->
    name = $("#user-name").val()
    socket.emit "user_updated", name
  
  self.confirmJoinGame = (gameId) ->
    return self.joinGame gameId unless root.game().isInGame()
    
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
      userId: self.currentId()
  
  self.leaveGame = ->
    root.alert null
    socket.emit "game_left",
      gameId: root.game().currentId()
      userId: self.currentId()
  
  self

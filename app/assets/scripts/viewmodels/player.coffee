@Avalon ?= {}
Avalon.Player = (socket, root) ->
  self = this
  
  self.current = ko.observable({})
  self.error = ko.observable({})
  
  self.currentId = ko.pureComputed((-> self.current()._id ), self)
  
  self.hasError = ko.pureComputed((->
    self.error()? and not $.isEmptyObject self.error()
  ), self)
  
  self.isGameCreator = ko.pureComputed((->
    root.game().currentCreatorName() is self.current().name
  ), self)
  
  self.update = ->
    name = root.inputVal "player", "name"
    socket.emit "player_updated", name
  
  self.joinGame = (gameId) ->
    socket.emit "game_joined",
      gameId: gameId
      playerId: self.currentId()
  
  self.leaveGame = ->
    root.alert null
    socket.emit "game_left",
      gameId: root.game().currentId()
      playerId: self.currentId()
  
  self

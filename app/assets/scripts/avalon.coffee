@Avalon ?= {}
Avalon.Main = (socket) ->
  self = this
  
  player = null
  game = null
  quest = null
  
  self.player = -> player = player || new Avalon.Player socket, self
  self.game = -> game = game || new Avalon.Game socket, self
  self.quest = -> quest = quest || new Avalon.Quest socket, self
  
  self.currentPage = ko.observable()
  self.alert = ko.observable()
  self.confirmDialog = ko.observable({})
  self.actionDialog = ko.observable({})
  self.waitingDialog = ko.observable({})
  self.infoDialog = ko.observable({})
  
  self.hasAlert = ko.pureComputed((->
    self.alert()? and not $.isEmptyObject self.alert()
  ), self)
  
  self.alertVote = ->
    unless $("#action-dialog").hasClass "in"
      self.alert
        message: "The king has made their final decision. Vote to accept or reject the proposed quest."
        type: "alert-warning"
  
  self.isCurrentPage = (pageName) ->
    self.currentPage() is pageName
  
  self.goToNewGame = ->
    self.game().error null
    self.currentPage "new_game"
    $("#game-name").focus()
  
  self.goToGames = ->
    self.currentPage "games"
  
  self.goToPlayer = ->
    self.currentPage "player"
    self.alert null
  
  self.goToNewQuestOutcome = ->
    self.currentPage "new_quest_outcome"
    self.alert null
  
  self

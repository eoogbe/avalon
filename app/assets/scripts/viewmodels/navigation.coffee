@Avalon ?= {}
Avalon.Navigation = (socket, root) ->
  self = this
  
  self.currentPage = ko.observable()
  
  self.isCurrentPage = (pageName) ->
    self.currentPage() is pageName
  
  self.goToNewGame = ->
    root.game().error null
    self.currentPage "new_game"
  
  self.goToGames = ->
    self.currentPage "games"
  
  self.goToPlayer = ->
    self.currentPage "player"
    root.alert null
  
  self.goToNewQuestOutcome = ->
    self.currentPage "new_quest_outcome"
    root.alert null
  
  self.goToQuest = ->
    self.currentPage "quest"
    root.alert null
  
  self.goToGameover = ->
    if root.game().isOver()
      self.currentPage "gameover"
    else if root.character().isAssassin()
      self.currentPage "merlin_selection"
    else
      root.waitingDialog
        message: "Waiting on Assassin"
        isDone: false
      $("#waiting-dialog").modal "show"
  
  self

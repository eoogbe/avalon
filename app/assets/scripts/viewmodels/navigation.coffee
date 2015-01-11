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
  
  self.goToNewQuestOutcome = ->
    self.currentPage "new_quest_outcome"
    root.alert null
  
  self.goToMerlinSelection = ->
    if root.character().isAssassin()
      self.currentPage "merlin_selection"
    else
      root.waitingDialogMsg "Waiting on Assassin"
      $("#waiting-dialog").modal "show"
  
  self.goToGameover = ->
    if root.game().isOver()
      self.currentPage "gameover"
    else
      self.goToMerlinSelection()
  
  self

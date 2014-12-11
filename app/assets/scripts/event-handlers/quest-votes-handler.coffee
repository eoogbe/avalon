@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.QuestVotes = (socket, viewModel) ->
  socket.on "set_votes", (votes) ->
    if viewModel.nav().isCurrentPage "new_questors"
      viewModel.questVote().list votes
      viewModel.questVote().alertNeeded()
  
  socket.on "alert_vote", ->
    viewModel.alertVote() if viewModel.nav().isCurrentPage "questors"
  
  socket.on "wait_on_voters", ->
    viewModel.alert null
    viewModel.waitingDialog
      message: "Waiting on voters"
      isDone: false
    $("#waiting-dialog").modal "show"
  
  socket.on "show_quest_votes", (data) ->
    viewModel.game().current data.currentGame
    viewModel.quest().current data.currentQuest
    viewModel.quest().isLastRejectableQuest data.isLastRejectableQuest
    viewModel.questVote().list data.votes
    viewModel.player().knownPlayers data.knownPlayers if data.knownPlayers?
    viewModel.character().characterStats data.characterStats if data.characterStats?
    
    viewModel.nav().currentPage "quest_votes"
    
    if viewModel.quest().isPlaying() and not viewModel.player().isQuestor()
      viewModel.alert
        message: "Waiting on questors..."
        type: "alert-warning"
    else
      viewModel.alert null
    
    viewModel.waitingDialog
      message: "All votes have been counted"
      isDone: true

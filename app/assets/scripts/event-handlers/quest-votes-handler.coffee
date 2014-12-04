@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.QuestVotes = (socket, viewModel) ->
  socket.on "alert_vote", ->
    viewModel.alertVote() if viewModel.isCurrentPage "questors"
  
  socket.on "wait_on_voters", ->
    viewModel.alert null
    viewModel.waitingDialog
      message: "Waiting on voters..."
      isDone: false
    $("#waiting-dialog").modal "show"
  
  socket.on "reject_quest", (currentQuest) ->
    viewModel.quest().current currentQuest
    viewModel.actionDialog
      type: "panel-default"
      heading: "Quest Rejected"
      message: "The quest was rejected"
      action: viewModel.quest().update
    viewModel.alert null
    $(".modal").modal "hide"
    $("#action-dialog").modal "show"

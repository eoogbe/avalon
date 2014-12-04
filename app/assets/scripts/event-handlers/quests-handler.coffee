@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Quests = (socket, viewModel) ->
  registerRadioListener = ->
    $(".quest-vote").change ->
      socket.emit "quest_voted_on",
        playerId: viewModel.player().currentId()
        questId: viewModel.quest().currentId()
        vote: @value
  
  socket.on "show_new_questors", (currentQuest) ->
    viewModel.quest().current currentQuest
    viewModel.currentPage "new_questors"
    registerRadioListener()
    viewModel.infoDialog
      heading: "King"
      message: "You are king"
    $("#info-dialog").modal "show"
  
  socket.on "show_questors", (currentQuest) ->
    viewModel.quest().current currentQuest
    viewModel.currentPage "questors"
    registerRadioListener()
    viewModel.alertVote() if currentQuest.state is "voting"
    viewModel.infoDialog
      heading: "King"
      message: "#{viewModel.quest().kingName()} is king"
    $("#info-dialog").modal "show"
  
  socket.on "set_quest", (currentQuest) ->
    unless viewModel.isCurrentPage "quest"
      viewModel.quest().current currentQuest
  
  socket.on "show_new_quest_outcome", (currentQuest) ->
    viewModel.quest().current currentQuest
    viewModel.currentPage "new_quest_outcome"
    viewModel.alert null
    viewModel.infoDialog
      heading: "Quest"
      message: "You are on the quest"
    $(".modal").modal "hide"
    $("#info-dialog").modal "show"
  
  socket.on "wait_on_questors", (currentQuest) ->
    viewModel.quest().current currentQuest
    viewModel.alert null
    viewModel.waitingDialog
      message: "Waiting on questors..."
      isDone: false
    $("#waiting-dialog").modal "show"
  
  socket.on "show_quest", (data) ->
    viewModel.quest().current data.quest
    viewModel.quest().stats data.questStats
    viewModel.currentPage "quest"
    viewModel.waitingDialog
      message: "All questors have finished"
      isDone: true

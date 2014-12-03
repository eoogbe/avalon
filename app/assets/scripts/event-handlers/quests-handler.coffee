@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Quests = (socket, viewModel) ->
  socket.on "show_new_questors", (currentQuest) ->
    viewModel.quest().current currentQuest
    viewModel.currentPage "new_questors"
    $("#info-dialog").modal "show"
  
  socket.on "show_questors", (currentQuest) ->
    viewModel.quest().current currentQuest
    viewModel.currentPage "questors"
    viewModel.alert
      message: "Waiting on king..."
      type: "alert-warning"
    $("#info-dialog").modal "show"
  
  socket.on "set_quest", (currentQuest) ->
    viewModel.quest().current currentQuest
  
  showWaitOnQuestorsDialog = ->
    viewModel.waitingDialog
      message: "Waiting on questors..."
      isDone: false
    $("#waiting-dialog").modal "show"
    viewModel.alert null
  
  socket.on "stop_waiting_on_king", (currentQuest) ->
    viewModel.quest().current currentQuest
    if viewModel.quest().hasQuestor viewModel.player().current()
      viewModel.alert
        message: 'The quest can
          <button
              id="start-quest-btn"
              type="button"
              data-bind="click: goToNewQuestOutcome"
          >
            start
          </button>!'
        type: "alert-success"
      ko.applyBindings viewModel, $("#start-quest-btn")[0]
    else
      showWaitOnQuestorsDialog()
  
  socket.on "show_new_quest_outcome", (currentQuest) ->
    viewModel.quest().current currentQuest
    viewModel.currentPage "new_quest_outcome"
    viewModel.alert null
  
  socket.on "wait_on_questors", (currentQuest) ->
    viewModel.quest().current currentQuest
    showWaitOnQuestorsDialog()
  
  socket.on "show_quest", (data) ->
    viewModel.quest().current data.quest
    viewModel.quest().stats data.questStats
    viewModel.currentPage "quest"
    viewModel.waitingDialog
      message: "All questors have finished"
      isDone: true

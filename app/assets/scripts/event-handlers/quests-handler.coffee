@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Quests = (socket, viewModel) ->
  socket.on "set_quest", (currentQuest) ->
    if viewModel.currentPage() in ["questors", "new_questors"]
      viewModel.quest().current currentQuest
  
  socket.on "show_new_quest_outcome", (data) ->
    viewModel.game().current data.currentGame
    viewModel.quest().current data.currentQuest
    viewModel.player().knownPlayers data.knownPlayers if data.knownPlayers?
    viewModel.quest().stats data.questStats if data.questStats?
    viewModel.currentPage "new_quest_outcome"
  
  socket.on "show_quest", (data) ->
    viewModel.quest().current data.quest
    viewModel.quest().stats data.questStats
    if viewModel.hasAlert()
      viewModel.alert
        message: 'All questors have finished.
          <button
              id="show-quest-btn"
              type="button"
              class="btn-link alert-link"
              data-bind="click: goToQuest"
          >
            See results
          </button>'
        type: "alert-info"
      ko.applyBindings viewModel, $("#show-quest-btn")[0]
    else
      viewModel.currentPage "quest"
      viewModel.waitingDialog
        message: "All questors have finished"
        isDone: true

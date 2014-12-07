@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Quests = (socket, viewModel) ->
  sendQuestVotedOn = ->
    socket.emit "quest_voted_on",
      playerId: viewModel.player().currentId()
      questId: viewModel.quest().currentId()
      vote: @value
  
  registerRadioListener = ->
    $(".quest-vote")
      .prop "checked", false
      .off "change", sendQuestVotedOn
      .on "change", sendQuestVotedOn
  
  socket.on "show_new_questors", (currentQuest) ->
    viewModel.quest().current currentQuest
    viewModel.currentPage "new_questors"
    registerRadioListener()
    viewModel.infoDialog
      heading: "King"
      message: 'You are king 
        <img
            src="/images/crown.jpg"
            width="54"
            height="30"
            aria-hidden="true"
        >'
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
    if viewModel.currentPage() in ["questors", "new_questors"]
      viewModel.quest().current currentQuest
  
  socket.on "wait_on_questors", (data) ->
    viewModel.game().current data.currentGame
    viewModel.quest().current data.currentQuest
    viewModel.alert null
    viewModel.waitingDialog
      message: "Waiting on questors..."
      isDone: false
    $("#waiting-dialog").modal "show"
  
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

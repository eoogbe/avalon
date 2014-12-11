@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Questors = (socket, viewModel) ->
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
    
    if viewModel.player().hasVoted()
      voteSelector = ".quest-vote[value=#{viewModel.player().vote()}]"
      $(voteSelector).prop "checked", true
  
  socket.on "show_new_questors", (data) ->
    viewModel.game().current data.currentGame
    viewModel.quest().current data.currentQuest
    viewModel.questVote().list data.votes
    viewModel.player().knownPlayers data.knownPlayers if data.knownPlayers?
    viewModel.quest().stats data.questStats if data.questStats?
    viewModel.character().characterStats data.characterStats if data.characterStats?
    viewModel.nav().currentPage "new_questors"
    registerRadioListener()
    viewModel.questVote().alertNeeded()
    viewModel.infoDialog
      heading: "King"
      message: 'You are king 
        <img
            src="/images/crown.jpg"
            alt=""
            width="54"
            height="30"
            aria-hidden="true"
        >'
    $("#info-dialog").modal "show"
  
  socket.on "show_questors", (data) ->
    viewModel.game().current data.currentGame
    viewModel.quest().current data.currentQuest
    viewModel.questVote().list data.votes
    viewModel.player().knownPlayers data.knownPlayers if data.knownPlayers?
    viewModel.quest().stats data.questStats if data.questStats?
    viewModel.character().characterStats data.characterStats if data.characterStats?
    viewModel.nav().currentPage "questors"
    registerRadioListener()
    viewModel.alertVote() if data.currentQuest.state is "voting"
    viewModel.infoDialog
      heading: "King"
      message: "#{viewModel.quest().kingName()} is king"
    $("#info-dialog").modal "show"
  
  socket.on "wait_on_questors", (data) ->
    viewModel.game().current data.currentGame
    viewModel.quest().current data.currentQuest
    viewModel.alert null
    viewModel.waitingDialog
      message: "Waiting on questors"
      isDone: false
    $("#waiting-dialog").modal "show"
  
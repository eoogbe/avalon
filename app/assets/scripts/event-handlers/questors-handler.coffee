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
    viewModel.game().players data.gamePlayers
    viewModel.quest().current data.currentQuest
    viewModel.quest().king data.king
    viewModel.quest().players data.questPlayers
    viewModel.questVote().list data.votes
    viewModel.questVote().approvers data.approvers
    viewModel.questVote().rejectors data.rejectors
    viewModel.player().current data.currentPlayer if data.currentPlayer?
    viewModel.player().knownPlayers data.knownPlayers if data.knownPlayers?
    viewModel.quest().stats data.questStats if data.questStats?
    viewModel.character().stats data.characterStats if data.characterStats?
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
    viewModel.game().players data.gamePlayers
    viewModel.quest().current data.currentQuest
    viewModel.quest().king data.king
    viewModel.quest().players data.questPlayers
    viewModel.questVote().list data.votes
    viewModel.questVote().approvers data.approvers
    viewModel.questVote().rejectors data.rejectors
    viewModel.player().current data.currentPlayer if data.currentPlayer?
    viewModel.player().knownPlayers data.knownPlayers if data.knownPlayers?
    viewModel.quest().stats data.questStats if data.questStats?
    viewModel.character().stats data.characterStats if data.characterStats?
    viewModel.nav().currentPage "questors"
    registerRadioListener()
    viewModel.alertVote() if data.currentQuest.state is "voting"
    viewModel.infoDialog
      heading: "King"
      message: "#{viewModel.quest().kingName()} is king"
    $("#info-dialog").modal "show"
  
  socket.on "wait_on_questors", (data) ->
    viewModel.game().current data.currentGame
    viewModel.game().players data.gamePlayers
    viewModel.quest().current data.currentQuest
    viewModel.quest().king data.king
    viewModel.quest().players data.questPlayers
    viewModel.alert null
    viewModel.waitingDialogMsg "Waiting on questors"
    $("#waiting-dialog").modal "show"
  
@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Quests = (socket, viewModel) ->
  socket.on "set_quest", (data) ->
    if viewModel.nav().currentPage() in ["questors", "new_questors"]
      viewModel.quest().current data.currentQuest
      viewModel.quest().king data.king
      viewModel.quest().players data.questPlayers
  
  socket.on "show_new_quest_outcome", (data) ->
    viewModel.player().current data.currentPlayer
    viewModel.player().knownPlayers data.knownPlayers
    viewModel.game().current data.currentGame
    viewModel.game().players data.gamePlayers
    viewModel.quest().current data.currentQuest
    viewModel.quest().king data.king
    viewModel.quest().players data.questPlayers
    viewModel.quest().stats data.questStats
    viewModel.character().stats data.characterStats
    viewModel.nav().currentPage "new_quest_outcome"
  
  socket.on "show_quest", (data) ->
    viewModel.game().current data.currentGame
    viewModel.game().players data.gamePlayers
    viewModel.quest().current data.currentQuest
    viewModel.quest().king data.king
    viewModel.quest().players data.questPlayers
    viewModel.quest().stats data.questStats
    viewModel.nav().currentPage "quest"
    viewModel.alert null
    $("#waiting-dialog").modal "hide"

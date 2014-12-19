@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Quests = (socket, viewModel) ->
  socket.on "set_quest", (currentQuest) ->
    if viewModel.nav().currentPage() in ["questors", "new_questors"]
      viewModel.quest().current currentQuest
  
  socket.on "show_new_quest_outcome", (data) ->
    viewModel.game().current data.currentGame
    viewModel.quest().current data.currentQuest
    viewModel.player().knownPlayers data.knownPlayers
    viewModel.quest().stats data.questStats
    viewModel.character().characterStats data.characterStats
    viewModel.nav().currentPage "new_quest_outcome"
  
  socket.on "show_quest", (data) ->
    viewModel.game().current data.currentGame
    viewModel.quest().current data.currentQuest
    viewModel.quest().stats data.questStats
    viewModel.nav().currentPage "quest"
    viewModel.alert null
    $("#waiting-dialog").modal "hide"

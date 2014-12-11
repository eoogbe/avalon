@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Main = (socket, viewModel) ->
  for handler in ["Players", "Characters", "Games", "Quests", "QuestVotes", "Questors"]
    Avalon.EventHandlers[handler] socket, viewModel

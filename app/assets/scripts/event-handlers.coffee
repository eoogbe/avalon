@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Main = (socket, viewModel) ->
  for handler in ["Players", "Games", "Quests"]
    Avalon.EventHandlers[handler] socket, viewModel
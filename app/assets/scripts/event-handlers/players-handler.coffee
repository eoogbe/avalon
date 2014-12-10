@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Players = (socket, viewModel) ->
  socket.on "show_edit_player", ->
    viewModel.currentPage "edit_player"
  
  socket.on "edit_player_error", (playerError) ->
    viewModel.player().error playerError
  
  socket.on "show_players", (data) ->
    viewModel.game().current data.currentGame
    viewModel.game().canStart data.canStartGame
    viewModel.currentPage "players"
    
    if not data.canStartGame
      viewModel.alert
        message: "Waiting for more players..."
        type: "alert-warning"
    else if not viewModel.player().isGameCreator()
      viewModel.alert
        message: "Waiting on game creator to start..."
        type: "alert-warning"
    else
      viewModel.alert null
  
  socket.on "set_player", (data) ->
    viewModel.player().current data.currentPlayer
    viewModel.player().knownPlayers data.knownPlayers
  
  socket.on "show_player", (currentGame) ->
    viewModel.game().current currentGame
    viewModel.quest().reset()
    viewModel.goToPlayer()

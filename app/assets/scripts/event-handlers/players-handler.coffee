@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Players = (socket, viewModel) ->
  socket.on "show_edit_player", ->
    viewModel.currentPage "edit_player"
    $("#player-name").focus()
  
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
  
  socket.on "set_player", (player) ->
    viewModel.player().current player
  
  socket.on "show_player", ->
    viewModel.goToPlayer()
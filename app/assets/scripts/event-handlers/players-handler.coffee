@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Players = (socket, viewModel) ->
  socket.on "show_edit_user", ->
    viewModel.quest().reset()
    viewModel.nav().currentPage "edit_user"
  
  socket.on "edit_user_error", (userError) ->
    viewModel.user().error userError
  
  socket.on "set_player", (currentPlayer) ->
    viewModel.player().current currentPlayer
  
  socket.on "show_players", (data) ->
    viewModel.game().current data.currentGame
    viewModel.game().players data.gamePlayers
    viewModel.nav().currentPage "players"
    viewModel.alert
      message: "Waiting for more players..."
      type: "alert-warning"
  
  socket.on "show_player", (data) ->
    viewModel.player().current data.currentPlayer
    viewModel.player().knownPlayers data.knownPlayers
    viewModel.game().current data.currentGame
    viewModel.character().stats data.characterStats
    viewModel.nav().currentPage "player"
    viewModel.alert null

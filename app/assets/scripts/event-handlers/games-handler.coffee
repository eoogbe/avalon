@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Games = (socket, viewModel) ->
  socket.on "show_games", (data) ->
    viewModel.game().list data.games
    viewModel.player().current data.currentPlayer if data.currentPlayer?
    viewModel.game().current data.currentGame if data.currentGame?
    viewModel.nav().currentPage "games"
    viewModel.alert null
  
  socket.on "new_game_error", (gameError) ->
    viewModel.game().error gameError
  
  socket.on "refresh_games", (games) ->
    viewModel.game().list games
  
  socket.on "warn_game_discontinued", ->
    viewModel.game().current {}
    viewModel.actionDialog
      type: "panel-danger"
      heading: "Game discontinued"
      message: "This game has been discontinued by another player and can no longer be played"
      action: viewModel.game().reload
    $("#action-dialog").modal "show"
  
  socket.on "warn_game_deleted", ->
    viewModel.actionDialog
      type: "panel-danger"
      heading: "Game deleted"
      message: "This game has been deleted by its owner"
      action: viewModel.game().reload
    $("#action-dialog").modal "show"
  
  socket.on "show_gameover", (currentGame) ->
    viewModel.game().current currentGame
    viewModel.nav().currentPage "gameover"
    $("#waiting-dialog").modal "hide"

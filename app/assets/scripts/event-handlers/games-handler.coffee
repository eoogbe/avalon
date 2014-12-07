@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Games = (socket, viewModel) ->
  socket.on "show_games", (data) ->
    viewModel.game().list data.games
    viewModel.player().current data.currentPlayer if data.currentPlayer?
    viewModel.currentPage "games"
    viewModel.alert null
  
  socket.on "new_game_error", (gameError) ->
    viewModel.game().error gameError
  
  socket.on "refresh_games", (games) ->
    viewModel.game().list games
  
  socket.on "warn_game_deleted", ->
    viewModel.actionDialog
      type: "panel-danger"
      heading: "Warning"
      message: "This game has been deleted by its owner"
      action: game().reload
    $("#action-dialog").modal "show"
  
  socket.on "stop_waiting_on_game_start", (currentGame) ->
    viewModel.game().current currentGame
    viewModel.alert
      message: 'The game can
        <button
            id="start-game-btn"
            type="button"
            class="btn-link alert-link"
            data-bind="click: goToPlayer"
        >
          start
        </button>!'
      type: "alert-success"
    ko.applyBindings viewModel, $("#start-game-btn")[0]
  
  socket.on "show_gameover", (game) ->
    viewModel.game().current game
    viewModel.currentPage "gameover"
    viewModel.alert null
    viewModel.waitingDialog
      message: "All questors have finished"
      isDone: true

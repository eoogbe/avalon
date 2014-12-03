@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Games = (socket, viewModel) ->
  socket.on "show_games", (data) ->
    viewModel.game().list data.games
    viewModel.player().current data.currentPlayer if data.currentPlayer?
    viewModel.currentPage "games"
  
  socket.on "new_game_error", (gameError) ->
    viewModel.game().error gameError
  
  socket.on "refresh_games", (games) ->
    viewModel.game().list games
  
  socket.on "warn_game_deleted", ->
    $("#warning-dialog").modal "show"
  
  socket.on "stop_waiting_on_game_start", ->
    viewModel.alert
      message: 'The game can
        <button
            id="start-game-btn"
            type="button"
            data-bind="click: goToPlayer"
        >
          start
        </button>!'
      type: "alert-success"
    ko.applyBindings viewModel, $("#start-game-btn")[0]
  
  socket.on "show_gameover", (game) ->
    viewModel.game().current game
    viewModel.currentPage "gameover"
    viewModel.waitingDialog
      message: "All questors have finished"
      isDone: true

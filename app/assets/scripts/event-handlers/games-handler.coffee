@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Games = (socket, viewModel) ->
  socket.on "show_games", (data) ->
    viewModel.game().list data.games
    viewModel.user().current data.currentUser if data.currentUser?
    viewModel.player().current data.currentPlayer if data.currentPlayer?
    viewModel.game().current data.currentGame if data.currentGame?
    viewModel.game().players data.gamePlayers if data.gamePlayers?
    viewModel.nav().currentPage "games"
    viewModel.alert null
  
  socket.on "new_game_error", (gameError) ->
    viewModel.game().error gameError
  
  socket.on "refresh_games", (games) ->
    viewModel.game().list games
  
  socket.on "warn_game_discontinued", ->
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
  
  socket.on "show_merlin_selection", (data) ->
    viewModel.player().current data.currentPlayer
    viewModel.player().knownPlayers data.knownPlayers
    viewModel.game().current data.currentGame
    viewModel.game().players data.gamePlayers
    viewModel.quest().stats data.questStats
    viewModel.character().stats data.characterStats
    viewModel.nav().goToMerlinSelection()
  
  socket.on "show_gameover", (data) ->
    viewModel.game().current data.currentGame
    viewModel.game().players data.gamePlayers
    viewModel.nav().currentPage "gameover"
    $("#waiting-dialog").modal "hide"

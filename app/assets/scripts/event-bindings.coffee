@Avalon ?= {}
Avalon.EventBindings = (socket, viewModel) ->
  socket.on "show_edit_player", ->
    viewModel.currentPage "edit_player"
    $("#player-name").focus()
  
  socket.on "edit_player_error", (playerError) ->
    viewModel.player().error playerError
  
  socket.on "show_games", (data) ->
    viewModel.game().list data.games
    viewModel.player().current data.currentPlayer if data.currentPlayer?
    viewModel.currentPage "games"
  
  socket.on "new_game_error", (gameError) ->
    viewModel.game().error gameError
  
  socket.on "refresh_games", (games) ->
    viewModel.game().list games
  
  socket.on "show_players", (data) ->
    viewModel.game().current data.currentGame
    viewModel.game().canStart data.canStartGame
    viewModel.currentPage "players"
    
    if not data.canStartGame
      viewModel.alert
        message: "Waiting for more players..."
        type: "alert-info"
    else if not viewModel.player().isGameCreator()
      viewModel.alert
        message: "Waiting on game creator to start..."
        type: "alert-info"
    else
      viewModel.alert null
  
  socket.on "warn_game_deleted", ->
    $("#warning-dialog").modal "show"
  
  socket.on "set_player", (player) ->
    viewModel.player().current player
  
  socket.on "show_player", ->
    viewModel.goToPlayer()
  
  socket.on "stop_waiting_on_game_start", ->
    viewModel.alert
      message: 'The game can <button id="start-game-btn" type="button" data-bind="click: goToPlayer">begin</button>!'
      type: "alert-success"
    ko.applyBindings viewModel, $("#start-game-btn")[0]
  
  socket.on "show_new_quest_outcome", (data) ->
    viewModel.game().current data.currentGame
    viewModel.quest().current data.currentQuest
    viewModel.currentPage "new_quest_outcome"
  
  socket.on "waiting_to_finish_quest", ->
    viewModel.waitingDialog
      message: "Waiting on questors..."
      isDone: false
    $("#waiting-dialog").modal "show"
  
  socket.on "show_quest", (data) ->
    viewModel.quest().current data.quest
    viewModel.quest().stats data.questStats
    viewModel.currentPage "quest"
    viewModel.waitingDialog
      message: "All questors have finished"
      isDone: true
  
  socket.on "show_gameover", (game) ->
    viewModel.game().current game
    viewModel.currentPage "gameover"
    viewModel.waitingDialog
      message: "All questors have finished"
      isDone: true

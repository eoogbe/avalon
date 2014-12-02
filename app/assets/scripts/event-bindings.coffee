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
      viewModel.alert "Waiting for more players..."
    else if not viewModel.player().isGameCreator()
      viewModel.alert "Waiting on game creator to start..."
    else
      viewModel.alert null
  
  socket.on "warn_game_deleted", ->
    $("#warning-dialog").modal "show"
  
  socket.on "show_new_quest_outcome", (data) ->
    viewModel.game().current data.currentGame
    viewModel.quest().current data.currentQuest
    viewModel.currentPage "new_quest_outcome"
    viewModel.alert null
  
  socket.on "waiting_to_finish_quest", ->
    viewModel.alert "Waiting on quest-goers..."
  
  socket.on "show_quest", (data) ->
    viewModel.quest().current data.quest
    viewModel.quest().stats data.questStats
    viewModel.currentPage "quest"
    viewModel.alert null
  
  socket.on "show_gameover", (game) ->
    viewModel.game().current game
    viewModel.currentPage "gameover"
    viewModel.alert null

@Avalon.EventBindings = (socket, viewModel) ->
  socket.on "show_edit_player", ->
    viewModel.currentPage "edit_player"
    $("#player-name").focus()
  
  socket.on "new_player_error", (playerError) ->
    viewModel.playerError playerError
  
  socket.on "show_games", (data) ->
    viewModel.games data.games
    viewModel.currentPlayer data.currentPlayer if data.currentPlayer?
    viewModel.currentPage "games"
  
  socket.on "new_game_error", (gameError) ->
    viewModel.gameError gameError
  
  socket.on "waiting_to_start_game", ->
    viewModel.waitingDialogMsg "Waiting for more players..."
    $("#waiting").modal "show"
  
  socket.on "show_new_quest_outcome", (data) ->
    viewModel.currentGame data.currentGame
    viewModel.currentQuest data.currentQuest
    viewModel.currentPage "new_quest_outcome"
    $("#waiting").modal "hide"
  
  socket.on "waiting_to_finish_quest", ->
    viewModel.waitingDialogMsg "Waiting on quest-goers..."
    $("#waiting").modal "show"
  
  socket.on "show_quest", (data) ->
    viewModel.currentQuest data.quest
    viewModel.questStats data.questStats
    viewModel.currentPage "quest"
    $("#waiting").modal "hide"
  
  socket.on "show_gameover", (game) ->
    viewModel.currentGame game
    viewModel.currentPage "gameover"
    $("#waiting").modal "hide"

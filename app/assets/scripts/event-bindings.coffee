@Avalon.EventBindings = (socket, viewModel) ->
  socket.on "new_player_error", (playerError) ->
    viewModel.playerError playerError
  
  socket.on "show_games", (data) ->
    viewModel.games data.games
    viewModel.currentPlayer data.currentPlayer if data.currentPlayer?
    viewModel.currentPage "games"
  
  socket.on "new_game_error", (gameError) ->
    viewModel.gameError gameError
  
  socket.on "show_new_quest", (currentGame) ->
    viewModel.currentGame currentGame
    viewModel.currentPage "new_quest"
  
  socket.on "show_quest", (data) ->
    viewModel.currentQuest data.quest
    viewModel.questStats data.questStats
    viewModel.currentPage "quest"
  
  socket.on "show_gameover", (game) ->
    viewModel.currentGame game
    viewModel.currentPage "gameover"

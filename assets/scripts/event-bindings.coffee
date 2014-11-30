@Avalon.EventBindings = (socket, viewModel) ->
  socket.on "show_games", (games) ->
    viewModel.games games
    viewModel.currentPage "games"
  
  socket.on "new_game_error", (gameError) ->
    viewModel.gameError gameError
  
  socket.on "show_new_quest", (data) ->
    viewModel.currentGame data.currentGame
    viewModel.games data.games
    viewModel.currentPage "new_quest"
  
  socket.on "show_quest", (data) ->
    viewModel.currentQuest data.quest
    viewModel.questStats data.questStats
    viewModel.currentPage "quest"
  
  socket.on "show_gameover", (game) ->
    viewModel.currentGame game
    viewModel.currentPage "gameover"

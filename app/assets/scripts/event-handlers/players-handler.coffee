@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Players = (socket, viewModel) ->
  socket.on "show_edit_player", ->
    viewModel.quest().reset()
    viewModel.nav().currentPage "edit_player"
  
  socket.on "edit_player_error", (playerError) ->
    viewModel.player().error playerError
  
  socket.on "show_players", (currentGame) ->
    viewModel.game().current currentGame
    viewModel.nav().currentPage "players"
    
    unless currentGame.players.length is currentGame.characters.length
      viewModel.alert
        message: "Waiting for more players..."
        type: "alert-warning"
    else
      viewModel.alert
        message: 'The game can
          <button
              id="start-game-btn"
              type="button"
              class="btn-link alert-link"
              data-bind="click: game().start"
          >
            start
          </button>!'
        type: "alert-success"
      ko.applyBindings viewModel, $("#start-game-btn")[0]
  
  socket.on "show_player", (data) ->
    viewModel.game().current data.currentGame
    viewModel.player().current data.currentPlayer
    viewModel.player().knownPlayers data.knownPlayers
    viewModel.nav().goToPlayer()

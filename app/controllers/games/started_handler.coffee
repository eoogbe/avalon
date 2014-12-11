module.exports = (eventCtx) ->
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  Rules = eventCtx.models.Rules
  
  (data) ->
    Game.findByIdAndStart data.gameId, (err, game) ->
      return console.error err if err
      
      Player.findById data.playerId, (err, player) ->
        return console.error err if err
        
        socket.emit "show_player",
          currentGame: game
          currentPlayer: player
          knownPlayers: Rules.getPlayersKnown player, game.players

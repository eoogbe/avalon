module.exports = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  
  (gameId) ->
    Game.findByIdAndStart gameId, (err, game, characterStats) ->
      return console.error err if err
      
      socket.emit "show_new_characters",
        currentGame: game
        numGood: characterStats.numGood
        numBad: characterStats.numBad

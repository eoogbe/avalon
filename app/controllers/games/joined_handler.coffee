joinGame = require "./joiner"

module.exports = (eventCtx) ->
  Game = eventCtx.models.Game
  
  (data) ->
    Game.findById data.gameId, (err, game) ->
      return console.error err if err
      
      joinGame eventCtx, { player: data.playerId, game: game }

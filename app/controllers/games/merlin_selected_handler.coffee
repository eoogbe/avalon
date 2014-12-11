module.exports = (eventCtx) ->
  io = eventCtx.io
  Game = eventCtx.models.Game
  
  (data) ->
    Game.findByIdAndSelectMerlin data.gameId, data.merlinId, (err, game) ->
      return console.error err if err
        
      Game.populate game, { path: "players" }, (err, game) ->
        return console.error err if err
        
        io.to(game.name).emit "show_gameover", game

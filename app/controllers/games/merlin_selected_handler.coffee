module.exports = (eventCtx) ->
  io = eventCtx.io
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  
  (data) ->
    Game.findByIdAndSelectMerlin data.gameId, data.merlinId, (err, game) ->
      throw err if err
        
      Player.findGamePlayers game, (err, gamePlayers) ->
        throw err if err
        
        io.to(game.name).emit "show_gameover",
          currentGame: game
          gamePlayers: gamePlayers

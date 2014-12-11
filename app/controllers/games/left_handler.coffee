module.exports = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  showGames = eventCtx.showGames
  
  (data) ->
    Game.findByIdAndRemovePlayer data.gameId, data.playerId, (err, game) ->
      return console.error err if err
      
      Game.populate game, { path: "players" }, (err, game) ->
        return console.error err if err
        
        socket.leave game.name
        
        io.to(game.name).emit "show_players",
          currentGame: game
          canStartGame: game.canStart()
        
        showGames()

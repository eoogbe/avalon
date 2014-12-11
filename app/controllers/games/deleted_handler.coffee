module.exports = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  showGames = eventCtx.showGames
  
  (gameId) ->
    Game.findByIdAndRemove gameId, (err, game) ->
      return console.error err if err
      
      socket.broadcast.to(game.name).emit "warn_game_deleted"
      
      for id, conn of io.of("/").connected when game.name in conn.rooms
        conn.leave game.name
      
      showGames()

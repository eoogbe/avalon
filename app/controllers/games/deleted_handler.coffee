module.exports = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  
  (gameId) ->
    Game.findByIdAndRemove gameId, (err, game) ->
      throw err if err
      
      socket.broadcast.to(game.name).emit "warn_game_deleted"
      
      for id, conn of io.of("/").connected when game.name in conn.rooms
        conn.leave game.name
      
      Game.findUnstarted().lean().exec (err, games) ->
        throw err if err
        
        io.emit "refresh_games", games
        socket.emit "show_games", games: games

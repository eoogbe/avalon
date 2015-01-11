module.exports = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  showGames = eventCtx.showGames
  
  (data) ->
    Game.findByIdAndRemovePlayer data.gameId, data.userId, (err, game) ->
      throw err if err
      
      Player.findGamePlayers game, (err, gamePlayers) ->
        throw err if err
        
        socket.leave game.name
        io.to(game.name).emit "show_players",
          currentGame: game
          gamePlayers: gamePlayers
        
        showGames()

exports.created = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  
  (data) ->
    Game.findByIdAndSetup data.gameId, data.characters
      .populate "creator"
      .exec (err, game) ->
        throw err if err
        
        Player.findGamePlayers game, (err, gamePlayers) ->
          throw err if err
          
          Game.findUnstarted().lean().exec (err, games) ->
            throw err if err
            
            io.emit "refresh_games", games
            socket.emit "show_players",
              currentGame: game
              gamePlayers: gamePlayers

exports.created = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  
  (data) ->
    Game.findByIdAndSetup data.gameId, data.characters
      .populate "players creator"
      .exec (err, game) ->
        return console.error err if err
        
        Game.findUnstarted().lean().exec (err, games) ->
          return console.error err if err
          
          io.emit "refresh_games", games
          socket.emit "show_players", game

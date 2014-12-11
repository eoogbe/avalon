joinGame = require "./joiner"

module.exports = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  
  (data) ->
    Game.create { name: data.name, creator: data.playerId }, (err, game) ->
      if not err
        Game.unstarted().lean().exec (err, games) ->
          return console.error err if err
          
          io.emit "refresh_games", games
          joinGame eventCtx, { player: game.creator, game: game }
      else if err.name is "ValidationError"
        socket.emit "new_game_error", err.errors
      else
        console.error err

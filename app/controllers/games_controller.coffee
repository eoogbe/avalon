joinGame = (eventCtx, models) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  player = models.player
  game = models.game
  
  game.addPlayer player, (err, game) ->
    return console.error err if err
    
    populatedFields = [{ path: "creator" }, { path: "players" }]
    Game.populate game, populatedFields, (err, game) ->
      return console.error err if err
      
      socket.join game.name
      
      io.to(game.name).emit "show_players",
        currentGame: game
        canStartGame: game.canStart()

exports.created = (eventCtx) ->
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

exports.joined = (eventCtx) ->
  Game = eventCtx.models.Game
  
  (data) ->
    Game.findById data.gameId, (err, game) ->
      return console.error err if err
      
      joinGame eventCtx, { player: data.playerId, game: game }

exports.left = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  showGames = eventCtx.showGames
  
  (data) ->
    Game.findByIdAndRemovePlayer data.gameId, data.playerId, (err, game) ->
      return console.error err if err
      
      Game.populate game, { path: "players" }, (err, game) ->
        socket.leave game.name
        
        io.to(game.name).emit "show_players",
          currentGame: game
          canStartGame: game.canStart()
        
        showGames()

exports.started = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  
  (gameId) ->
    Game.findByIdAndUpdate(gameId, { state: "playing" })
      .populate("players")
      .exec (err, game) ->
        return console.error err if err
        
        game.start (err) ->
          return console.error err if err
          
          for id, conn of io.of("/").connected when game.name in conn.rooms
            currentPlayer = conn.request.session.user
            for player in game.players when player.name is currentPlayer
              conn.emit "set_player", player
              break
          
          socket.emit "show_player"
          socket.to(game.name).emit "stop_waiting_on_game_start"

exports.deleted = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  showGames = eventCtx.showGames
  
  (gameId) ->
    Game.findByIdAndRemove gameId, (err, game) ->
      return console.error err if err
      
      socket.leave game.name
      io.to(game.name).emit "warn_game_deleted"
      
      for id, conn of io.of("/").connected when game.name in conn.rooms
        conn.leave game.name
      
      showGames()

exports.reloaded = (eventCtx) ->
  eventCtx.showGames

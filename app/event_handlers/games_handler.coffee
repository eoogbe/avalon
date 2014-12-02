async = require "async"

MersenneTwister = require "mersennetwister"
rng = new MersenneTwister()

randChoice = (arr) ->
  randIdx = rng.int() % arr.length
  arr[randIdx]

joinGame = (eventCtx, models) ->
  io = eventCtx.io
  socket = eventCtx.socket
  player = models.player
  game = models.game
  
  player.join game, (err, game) ->
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
      if !err
        Game.populate game, [{ path: 'players' }, { path: 'creator' }], (err, game) ->
          return console.error err if err
          
          Game.unstarted (err, games) ->
            return console.error err if err
            
            io.emit "refresh_games", games
            joinGame eventCtx, { player: game.creator, game: game }
      else if err.name is "ValidationError"
        socket.emit "new_game_error", err.errors
      else
        console.error err

exports.joined = (eventCtx) ->
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  
  (data) ->
    Player.findById data.playerId, (err, player) ->
      return console.error err if err
      
      Game.findById(data.gameId).populate("players creator").exec (err, game) ->
        return console.error err if err
        
        joinGame eventCtx, { player: player, game: game }

exports.left = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  showGames = eventCtx.showGames
  
  (data) ->
    Player.findById data.playerId, (err, player) ->
      return console.error err if err
      
      player.leave data.gameId, (err, game) ->
        return console.error err if err
        
        socket.leave game.name
        
        io.to(game.name).emit "show_players",
          currentGame: game
          canStartGame: game.canStart()
        
        showGames()

exports.started = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  session = eventCtx.session
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  
  (gameId) ->
    Game.findByIdAndUpdate(gameId, { state: "playing" }).populate("players").exec (err, game) ->
      return console.error err if err
      
      async.eachLimit game.players, 1, ((player, done) ->
        player.character = randChoice Player.CHARACTERS
        player.save done
      ), (err) ->
        return console.error err if err
        
        Game.findById(gameId).populate("players").exec (err, game) ->
          return console.error err if err
          
          for id, conn of io.of("/").connected when conn.rooms.indexOf(game.name) >= 0
            for player in game.players when player.name is conn.request.session.user
              conn.emit "set_player", player
          
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
      
      for id, conn of io.of("/").connected when conn.rooms.indexOf(game.name) >= 0
        conn.leave game.name
      
      showGames()

exports.reloaded = (eventCtx) ->
  eventCtx.showGames

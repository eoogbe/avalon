joinGame = (eventCtx, models) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Quest = eventCtx.models.Quest
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
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  
  (data) ->
    Player.findById data.playerId, (err, player) ->
      return console.error err if err
      
      Game.create { name: data.name, creator: player }, (err, game) ->
        if !err
          Game.populate game, [{ path: 'players' }, { path: 'creator' }], (err, game) ->
            return console.error err if err
            
            Game.unstarted (err, games) ->
              return console.error err if err
              
              io.emit "refresh_games", games
              joinGame eventCtx, { player: player, game: game }
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
  Game = eventCtx.models.Game
  Quest = eventCtx.models.Quest
  
  (gameId) ->
    Game.findByIdAndUpdate gameId, { state: "playing" }, (err, game) ->
      return console.error err if err
      
      Quest.create { game: game }, (err, quest) ->
        return console.error err if err
        
        io.to(game.name).emit "show_new_quest_outcome",
          currentGame: game
          currentQuest: quest

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

joinGame = (eventCtx, models) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Quest = eventCtx.models.Quest
  player = models.player
  game = models.game
  
  player.join game, (err, game) ->
    return console.error err if err
    
    socket.join game.name
    game.checkStartable (isPlaying) ->
      if isPlaying
        Quest.create { game: game }, (err, quest) ->
          return console.error err if err
          
          io.to(game.name).emit "show_new_quest_outcome",
            currentGame: game
            currentQuest: quest
      else
        socket.emit "waiting_to_start_game"

exports.created = (eventCtx) ->
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  
  (data) ->
    Game.create { name: data.name }, (err, game) ->
      if !err
        Player.findById data.playerId, (err, player) ->
          return console.error err if err
          
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
      
      Game.findById data.gameId, (err, game) ->
        return console.error err if err
        
        joinGame eventCtx, { player: player, game: game }

exports.gameover = (eventCtx, showGames) ->
  -> showGames()

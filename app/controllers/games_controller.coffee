joinGame = (eventCtx, models) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  player = models.player
  game = models.game
  
  Game.findOneAndUpdate { players: player, state: "playing" },
    { state: "discontinued" }, (err, oldGame) ->
      return console.error err if err
      
      if oldGame
        socket.broadcast.to(oldGame.name).emit "warn_game_discontinued"
        
        for id, conn of io.of("/").connected when oldGame.name in conn.rooms
          conn.leave oldGame.name
      
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
        return console.error err if err
        
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
    Game.findById(gameId).populate("players").exec (err, game) ->
      return console.error err if err
      
      game.start (err) ->
        return console.error err if err
        
        for id, conn of io.of("/").connected when game.name in conn.rooms
          currentPlayer = conn.request.session.user
          for player in game.players when player.name is currentPlayer
            conn.emit "set_player",
              currentPlayer: player
              knownPlayers: game.playersKnownTo player
            break
        
        socket.emit "show_player", game
        socket.broadcast.to(game.name).emit "stop_waiting_on_game_start", game

exports.deleted = (eventCtx) ->
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

exports.continued = (eventCtx) ->
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  Quest = eventCtx.models.Quest
  QuestVote = eventCtx.models.QuestVote
  upsertQuest = eventCtx.upsertQuest
  
  (data) ->
    Quest.findOne({ game: data.gameId, state: "playing" })
      .populate("game players king")
      .exec (err, quest) ->
        return console.error err if err
        
        Player.findById data.playerId, (err, player) ->
          return console.error err if err
          
          if not quest
            upsertQuest data.gameId, player
          else if quest.players.some((p) -> p.equals data.playerId)
            Game.findById(data.gameId).populate("players").exec (err, game) ->
              return console.error err if err
              
              socket.join game.name
              
              socket.emit "show_new_quest_outcome",
                currentGame: game
                currentQuest: quest
                knownPlayers: game.playersKnownTo player
          else
            QuestVote.find({ quest: quest })
              .populate("player")
              .exec (err, votes) ->
                return console.error err if err
                
                Game.populate quest.game, { path: "players" }, (err, game) ->
                  return console.error err if err
                  
                  socket.join game.name
                  
                  socket.emit "show_quest_votes",
                    currentGame: game
                    currentQuest: quest
                    isLastRejectableQuest: game.isOnLastRejectableQuest()
                    votes: votes
                    knownPlayers: game.playersKnownTo player

exports.reloaded = (eventCtx) ->
  eventCtx.showGames

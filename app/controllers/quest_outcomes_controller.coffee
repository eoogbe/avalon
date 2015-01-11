exports.created = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  Quest = eventCtx.models.Quest
  
  (data) ->
    Quest.findByIdAndCreateOutcome data.questId, data.outcome, (err, quest) ->
      throw err if err
      
      quest.checkFinished (err, isFinished) ->
        throw err if err
        
        Quest.populate quest, { path: "game" }, (err, quest) ->
          throw err if err
          
          Player.findQuestPlayers quest, (err, king, questPlayers) ->
            throw err if err
            
            if isFinished
              quest.game.checkGameover (err, data) ->
                throw err if err
                
                Player.findGamePlayers data.game, (err, gamePlayers) ->
                  throw err if err
                  
                  io.to(data.game.name).emit "show_quest",
                    currentGame: data.game
                    gamePlayers: gamePlayers
                    currentQuest: quest
                    king: king
                    questPlayers: questPlayers
                    questStats: data.questStats
            else
              Player.findGamePlayers quest.game, (err, gamePlayers) ->
                throw err if err
                
                socket.emit "wait_on_questors",
                  currentGame: quest.game
                  gamePlayers: gamePlayers
                  currentQuest: quest
                  king: king
                  questPlayers: questPlayers

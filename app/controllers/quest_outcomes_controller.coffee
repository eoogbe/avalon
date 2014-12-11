exports.created = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  Quest = eventCtx.models.Quest
  
  (data) ->
    Quest.findByIdAndCreateOutcome data.questId, data.outcome, (err, quest) ->
      return console.error err if err
      
      quest.checkFinished (err, isFinished) ->
        return console.error err if err
        
        populatedFields = [{ path: "game" }, { path: "players" }, { path: "king" }]
        Quest.populate quest, populatedFields, (err, quest) ->
          return console.error err if err
          
          if isFinished
            quest.game.checkGameover (err, data) ->
              return console.error err if err
              
              Game.populate data.game, { path: "players" }, (err, game) ->
                io.to(game.name).emit "show_quest",
                  currentGame: game
                  currentQuest: quest
                  questStats: data.questStats
          else
            Game.findById(quest.game).populate("players").exec (err, game) ->
              return console.error err if err
              
              socket.emit "wait_on_questors",
                currentGame: game
                currentQuest: quest

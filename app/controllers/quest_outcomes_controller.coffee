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
        
        if isFinished
          populatedFields = [{ path: "game" }, { path: "players" }]
          Quest.populate quest, populatedFields, (err, quest) ->
            return console.error err if err
            
            game = quest.game
            game.checkGameover (err, data) ->
              return console.error err if err
              
              if data.isGameover
                Game.populate game, { path: "players" }, (err, game) ->
                  return console.error err if err
                  
                  io.to(game.name).emit "show_gameover", data.game
              else
                io.to(game.name).emit "show_quest",
                  quest: quest
                  questStats: data.questStats
        else
          Game.findById(quest.game).populate("players").exec (err, game) ->
            return console.error err if err
            
            socket.emit "wait_on_questors",
              currentGame: game
              currentQuest: quest

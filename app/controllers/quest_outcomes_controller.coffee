exports.created = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Quest = eventCtx.models.Quest
  
  (data) ->
    changes = { $push: { outcomes: data.outcome }}
    Quest.findByIdAndUpdate data.questId, changes, (err, quest) ->
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
                io.to(game.name).emit "show_gameover", data.game
              else
                io.to(game.name).emit "show_quest",
                  quest: quest
                  questStats: data.questStats
        else
          socket.emit "wait_on_questors", quest

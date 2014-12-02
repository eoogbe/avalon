exports.created = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Quest = eventCtx.models.Quest
  
  (data) ->
    Quest.findById(data.questId).populate("game").exec (err, quest) ->
      return console.error err if err
      
      quest.createOutcome data.outcome, (err) ->
        return console.error err if err
        
        quest.checkFinished (isFinished) ->
          if isFinished
            game = quest.game
            game.checkGameover (data) ->
              if data.isGameover
                io.to(game.name).emit "show_gameover", data.game
              else
                io.to(game.name).emit "show_quest",
                  quest: quest
                  questStats: data.questStats
          else
            socket.emit "waiting_to_finish_quest"

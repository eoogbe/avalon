handleStateChange = (eventCtx, quest, nonvoters, noChangeFn) ->
  io = eventCtx.io
  Game = eventCtx.models.Game
  Quest = eventCtx.models.Quest
  QuestVote = eventCtx.models.QuestVote
  
  populatedFields = [{ path: "game" }, { path: "players" }, { path: "king" }]
  Quest.populate quest, populatedFields, (err, quest) ->
    return console.error err if err
    
    switch quest.state
      when "unstarted", "voting"
        noChangeFn quest
      when "rejected", "playing"
        QuestVote.find({ quest: quest }).populate("player").exec (err, votes) ->
          return console.error err if err
          
          Game.populate quest.game, { path: "players" }, (err, game) ->
            return console.error err if err
            
            io.to(game.name).emit "show_quest_votes",
              currentGame: game
              currentQuest: quest
              isLastRejectableQuest: game.isOnLastRejectableQuest()
              votes: votes
            
            if game.state is "bad_won"
              io.to(game.name).emit "show_gameover", game

exports.updated = (eventCtx) ->
  socket = eventCtx.socket
  session = socket.request.session
  Quest = eventCtx.models.Quest
  
  (gameId) ->
    Quest.upsert gameId, (err, quest) ->
      return console.error err if err
      
      populatedFields = [{ path: "king" }, { path: "players" }]
      Quest.populate quest, populatedFields, (err, quest) ->
        return console.error err if err
        
        isKing = quest.king.name is session.user
        page = if isKing then "new_questors" else "questors"
        socket.emit "show_#{page}", quest

exports.votedOn = (eventCtx) ->
  socket = eventCtx.socket
  Quest = eventCtx.models.Quest
  
  (data) ->
    Quest.findByIdAndCreateVote data.questId, data.playerId, data.vote,
      (err, quest, nonvoters) ->
        return console.error err if err
        
        handleStateChange eventCtx, quest, nonvoters, (quest) ->
          socket.emit "wait_on_voters" if quest.state is "voting"

exports.started = (eventCtx) ->
  io = eventCtx.io
  Quest = eventCtx.models.Quest
  
  (questId) ->
    Quest.findByIdAndUpdate questId, state: "voting"
      .populate "votes"
      .exec (err, quest) ->
        return console.error err if err
        
        quest.checkApproved (err, quest, nonvoters) ->
          return console.error err if err
          
          handleStateChange eventCtx, quest, nonvoters, (quest) ->
            for id, conn of io.of("/").connected when quest.game.name in conn.rooms
              currentPlayer = conn.request.session.user
              if nonvoters.some((player) -> player.name is currentPlayer)
                conn.emit "alert_vote"
              else
                conn.emit "wait_on_voters"

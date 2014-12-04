handleStateChange = (eventCtx, quest, nonvoters, noChangeFn) ->
  io = eventCtx.io
  Quest = eventCtx.models.Quest
  
  populatedFields = [{ path: "game" }, { path: "players" }]
  Quest.populate quest, populatedFields, (err, quest) ->
    return console.error err if err
    
    game = quest.game
    
    switch quest.state
      when "unstarted", "voting"
        noChangeFn quest
      when "rejected"
        io.to(game.name).emit "reject_quest", quest
      when "playing"
        for id, conn of io.of("/").connected when game.name in conn.rooms
          if quest.hasQuestor conn.request.session.user
            conn.emit "show_new_quest_outcome", quest
          else
            conn.emit "wait_on_questors", quest

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
    Quest.findByIdAndUpdate(questId, { state: "voting" })
      .populate("votes")
      .exec (err, quest) ->
        return console.error err if err
        
        quest.checkAccepted (err, quest, nonvoters) ->
          return console.error err if err
          
          handleStateChange eventCtx, quest, nonvoters, (quest) ->
            for id, conn of io.of("/").connected when quest.game.name in conn.rooms
              currentPlayer = conn.request.session.user
              if nonvoters.some((player) -> player.name is currentPlayer)
                conn.emit "alert_vote"
              else
                conn.emit "wait_on_voters"

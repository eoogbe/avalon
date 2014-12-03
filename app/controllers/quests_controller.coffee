exports.updated = (eventCtx) ->
  socket = eventCtx.socket
  session = socket.request.session
  Quest = eventCtx.models.Quest
  
  (data) ->
    questData = { game: data.gameId, state: data.state }
    Quest.upsert questData, (err, quest) ->
      return console.error err if err
      
      populatedFields = [{ path: "king" }, { path: "players" }]
      Quest.populate quest, populatedFields, (err, quest) ->
        return console.error err if err
        
        isKing = quest.king.name is session.user
        page = if isKing then "new_questors" else "questors"
        socket.emit "show_#{page}", quest

exports.started = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  session = socket.request.session
  Quest = eventCtx.models.Quest
  
  (questId) ->
    Quest.findByIdAndUpdate(questId, { state: "playing" })
      .populate("game players")
      .exec (err, quest) ->
        return console.error err if err
        
        if quest.players.some((p) -> p.name is session.user)
          socket.emit "show_new_quest_outcome", quest
        else
          socket.emit "wait_on_questors", quest
        
        socket.to(quest.game.name).emit "stop_waiting_on_king", quest

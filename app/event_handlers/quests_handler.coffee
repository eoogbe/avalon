exports.updated = (eventCtx) ->
  socket = eventCtx.socket
  Quest = eventCtx.models.Quest
  
  (gameId) ->
    questData = { game: gameId, state: "playing" }
    Quest.upsert(questData).populate("game").lean().exec (err, quest) ->
      return console.error err if err
      
      socket.emit "show_new_quest_outcome",
        currentGame: quest.game
        currentQuest: quest

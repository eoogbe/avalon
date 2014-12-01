exports.updated = (eventCtx) ->
  socket = eventCtx.socket
  Game = eventCtx.models.Game
  Quest = eventCtx.models.Quest
  
  (gameId) ->
    Game.findById gameId, (err, game) ->
      return console.error err if err
      
      questData = { game: game, state: "playing" }
      Quest.findOneAndUpdate(questData, {}, { upsert: true })
        .lean()
        .exec (err, quest) ->
          return console.error err if err
          
          socket.emit "show_new_quest_outcome",
            currentGame: game
            currentQuest: quest
  
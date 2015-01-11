handler = (eventCtx, changeType) ->
  io = eventCtx.io
  Player = eventCtx.models.Player
  Quest = eventCtx.models.Quest
  
  (data) ->
    Quest.findByIdAndUpdateQuestors data.questId, data.questorId, changeType
      .populate "game"
      .lean()
      .exec (err, quest) ->
        throw err if err
        
        Player.findQuestPlayers quest, (err, king, questPlayers) ->
          throw err if err
          
          io.to(quest.game.name).emit "set_quest",
            currentQuest: quest
            king: king
            questPlayers: questPlayers

exports.created = (eventCtx) ->
  handler eventCtx, "add"

exports.deleted = (eventCtx) ->
  handler eventCtx, "remove"

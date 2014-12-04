handler = (eventCtx, changeType) ->
  io = eventCtx.io
  Quest = eventCtx.models.Quest
  
  (data) ->
    Quest.findByIdAndUpdateQuestors(data.questId, data.questorId, changeType)
      .populate("game players")
      .lean()
      .exec (err, quest) ->
        return console.error err if err
        
        io.to(quest.game.name).emit "set_quest", quest

exports.created = (eventCtx) ->
  handler eventCtx, "add"

exports.deleted = (eventCtx) ->
  handler eventCtx, "remove"

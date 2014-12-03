handler = (eventCtx, changeType) ->
  io = eventCtx.io
  Quest = eventCtx.models.Quest
  
  (data) ->
    changes = {}
    changes[changeType] = { players: data.questorId }
    
    Quest.findByIdAndUpdate(data.questId, changes)
      .populate("game players")
      .lean()
      .exec (err, quest) ->
        return console.error err if err
        
        io.to(quest.game.name).emit "set_quest", quest

exports.created = (eventCtx) ->
  handler eventCtx, "$push"

exports.deleted = (eventCtx) ->
  handler eventCtx, "$pull"

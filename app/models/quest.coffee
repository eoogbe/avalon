mongoose = require "mongoose"

QuestSchema = mongoose.Schema
  state:
    type: String
    enum: ["unstarted", "playing", "succeeded", "failed"]
    default: "unstarted"
    required: true
  game:
    type: mongoose.Schema.Types.ObjectId
    ref: "Game"
    required: true
  king:
    type: mongoose.Schema.Types.ObjectId
    ref: "Player"
  players: [{ type: mongoose.Schema.Types.ObjectId, ref: "Player" }]
  outcomes: [Boolean]
  createdAt:
    type: Date
    default: Date.now
    required: true

NUM_OUTCOMES_TO_FINISH = 2

QuestSchema.statics.upsert = (conditions, done) ->
  changes = { $setOnInsert: { createdAt: Date.now() }}
  @findOneAndUpdate(conditions, changes, { upsert: true })
    .populate("game")
    .exec (err, quest) ->
      return done err if err
      
      if quest.king?
        done null, quest
      else
        quest.game.nextKing (err, king) ->
          return done err if err
          
          quest.king = king
          quest.save done

QuestSchema.methods.checkFinished = (done) ->
  if @outcomes.length >= NUM_OUTCOMES_TO_FINISH
    @state = if false in @outcomes then "failed" else "succeeded"
    @save (err) ->
      done err, true
  else
    done null, false

mongoose.model "Quest", QuestSchema

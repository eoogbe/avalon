mongoose = require "mongoose"

QuestSchema = mongoose.Schema
  state:
    type: String
    enum: ["playing", "succeeded", "failed"]
    default: "playing"
    required: true
  game:
    type: mongoose.Schema.Types.ObjectId
    ref: "Game"
    required: true
  outcomes: [Boolean]
  createdAt:
    type: Date
    default: Date.now
    required: true

NUM_OUTCOMES_TO_FINISH = 2

QuestSchema.statics.upsert = (conditions) ->
  @findOneAndUpdate conditions, {
    $setOnInsert: { createdAt: Date.now() }
  }, { upsert: true }

QuestSchema.methods.createOutcome = (outcome, done) ->
  @outcomes.push outcome
  @save done

QuestSchema.methods.checkFinished = (done) ->
  if @outcomes.length >= NUM_OUTCOMES_TO_FINISH
    @state = if @outcomes.indexOf(false) >= 0 then "failed" else "succeeded"
    @save (err) ->
      return console.error err if err
      
      done true
  else
    done false

mongoose.model "Quest", QuestSchema

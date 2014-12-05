mongoose = require "mongoose"

PlayerSchema = mongoose.Schema
  name:
    type: String
    required: true
    unique: true
  character:
    type: String
    enum: ["Good", "Bad"]
  createdAt:
    type: Date
    default: Date.now
    required: true

PlayerSchema.statics.upsert = (conditions) ->
  @findOneAndUpdate conditions, {
    $setOnInsert: { createdAt: Date.now() }
  }, { upsert: true }

mongoose.model "Player", PlayerSchema

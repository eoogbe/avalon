mongoose = require "mongoose"

CHARACTERS = ["Good", "Bad"]

PlayerSchema = mongoose.Schema
  name:
    type: String
    required: true
    unique: true
  character:
    type: String
    enum: CHARACTERS
  createdAt:
    type: Date
    default: Date.now
    required: true

PlayerSchema.statics.CHARACTERS = CHARACTERS

PlayerSchema.statics.upsert = (conditions) ->
  @findOneAndUpdate conditions, {
    $setOnInsert: { createdAt: Date.now() }
  }, { upsert: true }

mongoose.model "Player", PlayerSchema

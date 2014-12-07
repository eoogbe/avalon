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

PlayerSchema.statics.upsert = (conditions, done) ->
  Player = this
  
  Player.findOne conditions, (err, player) ->
    if err
      done err
    else if player
      done null, player
    else
      Player.create conditions, done

mongoose.model "Player", PlayerSchema

mongoose = require "mongoose"

PlayerSchema = mongoose.Schema
  name:
    type: String
    required: true
    unique: true
  createdAt:
    type: Date
    default: Date.now
    required: true

PlayerSchema.methods.join = (game, done) ->
  game.state = "playing"
  game.players.push this
  game.save done

mongoose.model "Player", PlayerSchema

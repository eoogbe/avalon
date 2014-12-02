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

PlayerSchema.methods.join = (game, done) ->
  player = this
  
  unless game.players.some((p) -> p.equals(player))
    game.players.push player
    game.save done
  else
    done null, game

PlayerSchema.methods.leave = (gameId, done) ->
  changes = { $pull: { players: @_id }}
  @model("Game").findByIdAndUpdate(gameId, changes)
    .populate("players")
    .exec done

mongoose.model "Player", PlayerSchema

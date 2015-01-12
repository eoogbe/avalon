mongoose = require "mongoose"

PlayerSchema = mongoose.Schema
  character:
    type: String
    enum: ["good", "bad", "assassin", "merlin", "mordred", "morgana", "percival", "oberon"]
  game:
    type: mongoose.Schema.Types.ObjectId
    ref: "Game"
    required: true
  user:
    type: mongoose.Schema.Types.ObjectId
    ref: "User"
    required: true
  createdAt:
    type: Date
    default: Date.now
    required: true

CURRENT_GAME_STATES = ["setup", "playing", "assassinating"]

PlayerSchema.statics.upsert = (conditions, done) ->
  changes = { $setOnInsert: { createdAt: Date.now() }}
  @findOneAndUpdate conditions, changes, { upsert: true }, done

PlayerSchema.statics.findCurrent = (user, done) ->
  Player = this
  Game = @model "Game"
  
  Game.find { state: { $in: CURRENT_GAME_STATES }}, (err, games) ->
    return done err, null if err or games.length is 0 # need to return null if no player
    
    Player.findOne { user: user, game: { $in: games }}, done

PlayerSchema.statics.findGamePlayers = (game, done) ->
  @find({ _id: { $in: game.players }}).populate("user").exec done

PlayerSchema.statics.findQuestPlayers = (quest, done) ->
  Player = this
  
  Player.findById(quest.king).populate("user").exec (err, king) ->
    return done err, king, [] if err or quest.players.length is 0
    
    conditions = { _id: { $in: quest.players }}
    Player.find(conditions).populate("user").exec (err, players) ->
      done err, king, players

PlayerSchema.statics.findVoters = (votes, done) ->
  voterIds = votes.map (vote) -> vote.player
  @find({ _id: { $in: voterIds }}).populate("user").exec (err, voters) ->
    return done err if err
    
    approvers = voters.filter (voter) ->
      votes.some (vote) -> vote.player.equals(voter._id) and vote.isApprove
    
    rejectors = voters.filter (voter) ->
      votes.some (vote) -> vote.player.equals(voter._id) and not vote.isApprove
    
    done null, approvers, rejectors

mongoose.model "Player", PlayerSchema

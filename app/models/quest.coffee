mongoose = require "mongoose"
Rules = require "./rules"

QuestSchema = mongoose.Schema
  state:
    type: String
    enum: ["unstarted", "voting", "rejected", "playing", "succeeded", "failed"]
    default: "unstarted"
    required: true
  numPlayersNeeded:
    type: Number
    min: 2
    required: true
  numFailsRequired:
    type: Number
    min: 1
    max: 2
    required: true
  game:
    type: mongoose.Schema.Types.ObjectId
    ref: "Game"
    required: true
  king:
    type: mongoose.Schema.Types.ObjectId
    ref: "Player"
    required: true
  players: [{ type: mongoose.Schema.Types.ObjectId, ref: "Player" }]
  votes: [{ type: mongoose.Schema.Types.ObjectId, ref: "QuestVote" }]
  outcomes: [Boolean]
  createdAt:
    type: Date
    default: Date.now
    required: true

NEW_QUEST_STATES = ["unstarted", "voting"]

QuestSchema.statics.upsert = (gameId, done) ->
  Quest = this
  Game = @model "Game"
  
  Quest.find { game: gameId, state: { $ne: "rejected" }}, (err, quests) ->
    return done err if err
    
    newQuests = quests.filter (quest) ->
      NEW_QUEST_STATES.indexOf(quest.state) >= 0
    return done null, newQuests[0] if newQuests.length > 0
    
    Game.findById(gameId).populate("players").exec (err, game) ->
      return done err if err
      
      game.nextKing (err, king) ->
        return done err if err
        
        questData =
          game: game
          numPlayersNeeded:
            Rules.getNumPlayersNeeded game.players.length, quests.length
          numFailsRequired:
            Rules.getNumFailsRequired game.players.length, quests.length
          king: king
        
        Quest.create questData, done

QuestSchema.statics.statsFor = (game, done) ->
  Quest = this
  
  Quest.count { game: game, state: "succeeded" }, (err, numSucceeded) ->
    return done err if err
    
    Quest.count { game: game, state: "failed" }, (err, numFailed) ->
      done err, { numSucceeded: numSucceeded, numFailed: numFailed }

QuestSchema.statics.findByIdAndCreateOutcome = (questId, outcome, done) ->
  @findByIdAndUpdate questId, { $push: { outcomes: outcome }}, done

QuestSchema.statics.findByIdAndUpdateQuestors = (questId, questorId, changeType) ->
  changeName = if changeType is "add"
    "$push"
  else if changeType is "remove"
    "$pull"
  
  changes = {}
  changes[changeName] = { players: questorId }
  
  @findByIdAndUpdate questId, changes

QuestSchema.statics.findByIdAndCreateVote = (questId, playerId, vote, done) ->
  Quest = @model "Quest"
  QuestVote = @model "QuestVote"
  
  voteConditions = { quest: questId, player: playerId }
  voteChanges =
    isApprove: vote is "approve"
    $setOnInsert: { createdAt: Date.now() }
  
  QuestVote.findOneAndUpdate voteConditions, voteChanges, { upsert: true },
    (err, vote) ->
      return done err if err
      
      questChanges = { $addToSet: { votes: vote._id }}
      Quest.findByIdAndUpdate questId, questChanges
        .populate "votes"
        .exec (err, quest) ->
          return done err if err
          
          quest.checkApproved done

QuestSchema.methods.hasVoter = (player) ->
  @votes.some (vote) -> vote.player.equals player._id

QuestSchema.methods.isApproved = ->
  approves = @votes.filter (vote) -> vote.isApprove
  approves.length > @votes.length / 2

QuestSchema.methods.checkApproved = (done) ->
  quest = this
  Game = @model "Game"
  
  Game.findById(quest.game).populate("players").exec (err, game) ->
    return done err if err
    
    players = game.players
    nonvoters = (player for player in players when not quest.hasVoter player)
    
    if nonvoters.length > 0
      done null, quest, nonvoters
    else if quest.state is "voting"
      if quest.isApproved()
        game.numRejectedQuests = 0
        quest.state = "playing"
      else
        ++game.numRejectedQuests
        quest.state = "rejected"
        if game.numRejectedQuests >= Game.MAX_REJECTED_QUESTS
          game.state = "bad_won"
      
      game.save (err) ->
        return done err if err
        
        quest.save done
    else
      done null, quest, nonvoters

QuestSchema.methods.checkFinished = (done) ->
  if @outcomes.length >= @numPlayersNeeded
    numFails = (outcome for outcome in @outcomes when outcome is false).length
    @state = if numFails >= @numFailsRequired then "failed" else "succeeded"
    @save (err) -> done err, true
  else
    done null, false

mongoose.model "Quest", QuestSchema

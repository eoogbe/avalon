mongoose = require "mongoose"

QuestSchema = mongoose.Schema
  state:
    type: String
    enum: ["unstarted", "voting", "rejected", "playing", "succeeded", "failed"]
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
  votes: [{ type: mongoose.Schema.Types.ObjectId, ref: "QuestVote" }]
  outcomes: [Boolean]
  createdAt:
    type: Date
    default: Date.now
    required: true

NUM_OUTCOMES_TO_FINISH = 2

QuestSchema.statics.upsert = (game, done) ->
  conditions = { game: game, state: { $in: ["unstarted", "voting"] }}
  changes = { $setOnInsert: { createdAt: Date.now(), state: "unstarted" }}
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
  Quest = @model("Quest")
  QuestVote = @model("QuestVote")
  
  voteConditions = { quest: questId, player: playerId }
  voteChanges =
    isAccept: vote is "accept"
    $setOnInsert: { createdAt: Date.now() }
  
  QuestVote.findOneAndUpdate voteConditions, voteChanges, { upsert: true },
    (err, vote) ->
      return done err if err
      
      questChanges = { $addToSet: { votes: vote._id }}
      Quest.findByIdAndUpdate(questId, questChanges)
        .populate("votes")
        .exec (err, quest) ->
          return done err if err
          
          quest.checkAccepted done

QuestSchema.methods.hasVoter = (player) ->
  @votes.some (vote) -> vote.player.equals player._id

QuestSchema.methods.hasQuestor = (playerName) ->
  @players.some (player) -> player.name is playerName

QuestSchema.methods.isAccepted = ->
  accepts = @votes.filter (vote) -> vote.isAccept
  accepts.length > @votes.length / 2

QuestSchema.methods.checkAccepted = (done) ->
  quest = this
  
  @model("Game").findById(quest.game).populate("players").exec (err, game) ->
    return done err if err
    
    players = game.players
    nonvoters = (player for player in players when not quest.hasVoter player)
    
    if nonvoters.length > 0
      done null, quest, nonvoters
    else if quest.state is "voting"
      quest.state = if quest.isAccepted() then "playing" else "rejected"
      quest.save done

QuestSchema.methods.checkFinished = (done) ->
  if @outcomes.length >= NUM_OUTCOMES_TO_FINISH
    @state = if false in @outcomes then "failed" else "succeeded"
    @save (err) ->
      done err, true
  else
    done null, false

mongoose.model "Quest", QuestSchema

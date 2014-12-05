mongoose = require "mongoose"

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
NUM_PLAYERS_NEEDED_PER_QUEST = [2, 3, 2, 3, 3]

QuestSchema.statics.upsert = (gameId, done) ->
  Quest = this
  Game = @model("Game")
  
  Quest.find { game: gameId }, (err, quests) ->
    return done err if err
    
    newQuests = quests.filter (quest) ->
      NEW_QUEST_STATES.indexOf(quest.state) >= 0
    return done null, newQuests[0] if newQuests.length > 0
    
    Game.findById gameId, (err, game) ->
      return done err if err
      
      game.nextKing (err, king) ->
        return done err if err
        
        questData =
          game: game
          numPlayersNeeded: NUM_PLAYERS_NEEDED_PER_QUEST[Math.min(quests.length, 4)]
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
  if @outcomes.length >= @numPlayersNeeded
    @state = if false in @outcomes then "failed" else "succeeded"
    @save (err) ->
      done err, true
  else
    done null, false

mongoose.model "Quest", QuestSchema

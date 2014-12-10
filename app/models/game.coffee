mongoose = require "mongoose"
async = require "async"
Random = require "./random"
Rules = require "./rules"
CharacterSelection = Rules.CharacterSelection

GameSchema = mongoose.Schema
  name:
    type: String
    required: true
    unique: true
  creator:
    type: mongoose.Schema.Types.ObjectId
    ref: "Player"
    required: true
  state:
    type: String
    enum: ["unstarted", "playing", "good_won", "bad_won", "discontinued"]
    default: "unstarted"
    required: true
  players: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Player' }]
  kingIdx:
    type: Number
    min: 0
  numRejectedQuests:
    type: Number
    min: 0
    max: 5
    default: 0
    required: true
  createdAt:
    type: Date
    default: Date.now
    required: true

NUM_QUESTS_TO_WIN = 3

GameSchema.path("name").validate(( (name, respond) ->
  return respond true unless @isModified "name"

  @model("Game").count { name: name }, (err, numGames) ->
    return respond false if err
    respond numGames is 0
  ), "already exists")

GameSchema.statics.MAX_REJECTED_QUESTS = 5

GameSchema.statics.unstarted = ->
  @find({ state: "unstarted" }).sort("-createdAt")

GameSchema.statics.findByIdAndRemovePlayer = (id, player, done) ->
  @findByIdAndUpdate id, { $pull: { players: player }}, done

GameSchema.methods.addPlayer = (player, done) ->
  unless @players.some((p) -> p.equals player)
    @players.push player
    @save done
  else
    done null, this

GameSchema.methods.start = (done) ->
  game = this
  
  game.kingIdx = Random.nextIdx(game.players)
  game.state = "playing"
  game.save (err, game) ->
    return done err if err
    
    characterSelection = new CharacterSelection game.players.length
    
    async.eachLimit game.players, 1, ((player, eachDone) ->
      player.character = characterSelection.assignCharacter()
      player.save eachDone
    ), done

GameSchema.methods.nextKing = (done) ->
  @kingIdx = (@kingIdx + 1) % @players.length
  @save (err, game) ->
    done err, game?.players?[game?.kingIdx]

GameSchema.methods.checkGameover = (done) ->
  game = this
  
  @model("Quest").statsFor game, (err, questStats) ->
    return done err if err
    
    gameover = (winnerType) ->
      game.state = "#{winnerType}_won"
      game.save (err) ->
        done err,
          isGameover: true
          questStats: questStats
          game: game
    
    if questStats.numSucceeded >= NUM_QUESTS_TO_WIN
      gameover "good"
    else if questStats.numFailed >= NUM_QUESTS_TO_WIN
      gameover "bad"
    else
      done null,
        isGameover: false
        questStats: questStats
        game: game

GameSchema.methods.canStart = ->
  @players.length >= Rules.MIN_PLAYERS

GameSchema.methods.playersKnownTo = (player) ->
  return [] if player.character is "Good"
  if player.character is "Bad"
    @players.filter (p) -> p.character is "Bad" and not p.equals player

GameSchema.methods.isOnLastRejectableQuest = ->
  @numRejectedQuests is @model("Game").MAX_REJECTED_QUESTS - 1

mongoose.model "Game", GameSchema

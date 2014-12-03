mongoose = require "mongoose"
async = require "async"

MersenneTwister = require "mersennetwister"
rng = new MersenneTwister()

randIdx = (arr) -> rng.int() % arr.length
randChoice = (arr) -> arr[randIdx(arr)]

GameSchema = mongoose.Schema
  name:
    type: String
    required: true
    unique: true
  creator:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Player'
    required: true
  state:
    type: String
    enum: ["unstarted", "playing", "good_won", "bad_won"]
    default: "unstarted"
    required: true
  players: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Player' }]
  kingIdx:
    type: Number
    min: 0
  createdAt:
    type: Date
    default: Date.now
    required: true

NUM_QUESTS_TO_WIN = 3
NUM_PLAYERS_TO_START = 3

GameSchema.path("name").validate(( (name, respond) ->
  return respond true unless @isModified "name"

  @model("Game").count { name: name }, (err, numGames) ->
    return respond false if err
    respond numGames is 0
  ), "already taken")

GameSchema.statics.unstarted = (done) ->
  @model("Game").find({ state: "unstarted" }).sort("-createdAt").lean().exec done

GameSchema.methods.start = (done) ->
  Game = @model("Game")
  Player = @model("Player")
  game = this
  
  game.kingIdx = randIdx(game.players)
  game.save (err, game) ->
    return done err if err
    
    async.eachLimit game.players, 1, ((player, eachDone) ->
      player.character = randChoice Player.CHARACTERS
      player.save eachDone
    ), (err) ->
      return done err if err
      
      Game.populate game, { path: "players" }, done

GameSchema.methods.nextKing = (done) ->
  @kingIdx = (@kingIdx + 1) % @players.length
  @save (err, game) ->
    done err, game?.players?[game?.kingIdx]

GameSchema.methods.checkGameover = (done) ->
  game = this
  
  game.questStats (err, questStats) ->
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

GameSchema.methods.questStats = (done) ->
  game = this
  
  game.model("Quest").count { game: game, state: "succeeded" }, (err, numSucceeded) ->
    return done err if err
    game.model("Quest").count { game: game, state: "failed" }, (err, numFailed) ->
      done err, { numSucceeded: numSucceeded, numFailed: numFailed }

GameSchema.methods.canStart = ->
  @players.length >= NUM_PLAYERS_TO_START

mongoose.model "Game", GameSchema

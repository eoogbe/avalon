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
NUM_PLAYERS_TO_START = 5

GameSchema.path("name").validate(( (name, respond) ->
  return respond true unless @isModified "name"

  @model("Game").count { name: name }, (err, numGames) ->
    return respond false if err
    respond numGames is 0
  ), "already taken")

GameSchema.statics.unstarted = ->
  @model("Game").find({ state: "unstarted" }).sort("-createdAt")

GameSchema.statics.findByIdAndRemovePlayer = (id, player, done) ->
  @findByIdAndUpdate id, { $pull: { players: player }}, done

GameSchema.methods.addPlayer = (player, done) ->
  unless @players.some((p) -> p.equals player)
    @players.push player
    @save done
  else
    done null, this

GameSchema.methods.start = (done) ->
  Game = @model("Game")
  Player = @model("Player")
  game = this
  
  characters = ["Good", "Good", "Good", "Bad", "Bad"]
  game.kingIdx = randIdx(game.players)
  game.save (err, game) ->
    return done err if err
    
    async.eachLimit game.players, 1, ((player, eachDone) ->
      if characters.length > 0
        player.character = randChoice characters
        removeIdx = characters.indexOf player.character
        characters.splice removeIdx, 1
      else
        player.character = randChoice ["Good", "Bad"]
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
  @players.length >= NUM_PLAYERS_TO_START

mongoose.model "Game", GameSchema

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
  state:
    type: String
    enum: ["setup", "unstarted", "playing", "assassinating", "good_won", "bad_won", "discontinued"]
    default: "setup"
    required: true
  characters: [String]
  players: [{ type: mongoose.Schema.Types.ObjectId, ref: "Player" }]
  kingIdx:
    type: Number
    min: 0
    max: 10
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

GameSchema.statics.findUnstarted = ->
  @find({ state: "unstarted" }).sort("-createdAt")

GameSchema.statics.findOneAndDiscontinue = (user, done) ->
  Game = this
  Player = @model "Player"
  
  Player.findCurrent user, (err, player) ->
    return done err, null if err or not player # need to return null if no game
    
    Game.findByIdAndUpdate player.game, { state: "discontinued" }, done

GameSchema.statics.findByIdAndSetup = (id, characters, done) ->
  @findByIdAndUpdate id, { state: "unstarted", characters: characters }

GameSchema.statics.findByIdAndAddPlayer = (id, player) ->
  @findByIdAndUpdate id, $addToSet: { players: player }

GameSchema.statics.findByIdAndRemovePlayer = (id, user, done) ->
  Game = this
  Player = @model "Player"
  
  Player.findOneAndRemove { game: id, user: user }, (err, player) ->
    return done err if err
    
    Game.findByIdAndUpdate id, { $pull: { players: player._id }}, done

GameSchema.statics.findByIdAndSelectMerlin = (id, merlinId, done) ->
  Player = @model "Player"
  Game = this
  
  Player.findById merlinId, (err, merlin) ->
    return done err if err
    
    winnerType = if merlin.character is "merlin" then "bad" else "good"
    Game.findByIdAndUpdate id, { state: "#{winnerType}_won" }, done

GameSchema.methods.start = (done) ->
  @state = "playing"
  @kingIdx = Random.nextIdx(@players)
  
  @save (err, game) ->
    return done err if err
    
    characterSelection = new CharacterSelection game.characters
    
    async.eachSeries game.players, ((player, next) ->
      player.character = characterSelection.assignCharacter()
      player.save next
    ), (err) -> done err, game

GameSchema.methods.nextKing = (done) ->
  @kingIdx = (@kingIdx + 1) % @players.length
  @save (err, game) ->
    done err, game?.players?[game?.kingIdx]

GameSchema.methods.checkGameover = (done) ->
  game = this
  Game = @model "Game"
  Quest = @model "Quest"
  
  Quest.statsFor game, (err, questStats) ->
    return done err if err
    
    gameover = (state) ->
      game.state = state
      game.save (err) ->
        done err, { questStats: questStats, game: game }
    
    if questStats.numSucceeded >= NUM_QUESTS_TO_WIN
      Game.populate game, { path: "players" }, (err, game) ->
        return done err if err
        
        gameover if game.hasAssassin() then "assassinating" else "good_won"
    else if questStats.numFailed >= NUM_QUESTS_TO_WIN
      gameover "bad_won"
    else
      done null, { questStats: questStats, game: game }

GameSchema.methods.hasAssassin = ->
  @players.some (player) -> player.character is "assassin"

GameSchema.methods.isOnLastRejectableQuest = ->
  @numRejectedQuests is @model("Game").MAX_REJECTED_QUESTS - 1

mongoose.model "Game", GameSchema

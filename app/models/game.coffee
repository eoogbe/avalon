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
    enum: ["unstarted", "setup", "playing", "assassinating", "good_won", "bad_won", "discontinued"]
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

GameSchema.statics.findByIdAndStart = (id, done) ->
  @findByIdAndUpdate id, { state: "setup" }, (err, game) ->
    done err, game, Rules.getCharacterStats game?.players?.length

GameSchema.statics.findByIdAndSetup = (id, characters, done) ->
  changes = { state: "playing" }
  @findByIdAndUpdate(id, changes).populate("players").exec (err, game) ->
    return done err if err
    
    game.kingIdx = Random.nextIdx(game.players)
    game.save (err) ->
      return done err if err
      
      characterSelection = new CharacterSelection characters
      
      async.eachLimit game.players, 1, ((player, eachDone) ->
        player.character = characterSelection.assignCharacter()
        player.save eachDone
      ), (err) -> done err, game

GameSchema.statics.findByIdAndRemovePlayer = (id, player, done) ->
  @findByIdAndUpdate id, { $pull: { players: player }}, done

GameSchema.statics.findByIdAndSelectMerlin = (id, merlinId, done) ->
  Player = @model "Player"
  Game = this
  
  Player.findById merlinId, (err, merlin) ->
    return done err if err
    
    winnerType = if merlin.character is "merlin" then "bad" else "good"
    Game.findByIdAndUpdate id, { state: "#{winnerType}_won" }, done

GameSchema.methods.addPlayer = (player, done) ->
  unless @players.some((p) -> p.equals player)
    @players.push player
    @save done
  else
    done null, this

GameSchema.methods.nextKing = (done) ->
  @kingIdx = (@kingIdx + 1) % @players.length
  @save (err, game) ->
    done err, game?.players?[game?.kingIdx]

GameSchema.methods.checkGameover = (done) ->
  game = this
  
  @model("Quest").statsFor game, (err, questStats) ->
    return done err if err
    
    gameover = (state) ->
      game.state = state
      game.save (err) ->
        done err, { questStats: questStats, game: game }
    
    if questStats.numSucceeded >= NUM_QUESTS_TO_WIN
      gameover "assassinating"
    else if questStats.numFailed >= NUM_QUESTS_TO_WIN
      gameover "bad_won"
    else
      done null, { questStats: questStats, game: game }

GameSchema.methods.canStart = ->
  @players.length >= Rules.MIN_PLAYERS

GameSchema.methods.playersKnownTo = (player) ->
  return [] if player.character is "good"
  if player.character in ["bad", "assassin", "merlin"]
    @players.filter (p) ->
      p.character in ["bad", "assassin"] and not p.equals player

GameSchema.methods.isOnLastRejectableQuest = ->
  @numRejectedQuests is @model("Game").MAX_REJECTED_QUESTS - 1

mongoose.model "Game", GameSchema

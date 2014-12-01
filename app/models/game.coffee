mongoose = require "mongoose"

GameSchema = mongoose.Schema
  name:
    type: String
    required: true
    unique: true
  state:
    type: String
    enum: ["unstarted", "playing", "good_won", "bad_won"]
    default: "unstarted"
    required: true
  players: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Player'}]
  createdAt:
    type: Date
    default: Date.now
    required: true

NUM_QUESTS_TO_WIN = 3
NUM_PLAYERS_TO_START = 2

GameSchema.path("name").validate(( (name, respond) ->
  return respond true unless @isModified "name"

  @model("Game").count { name: name }, (err, numGames) ->
    return respond false if err
    respond numGames is 0
  ), "already taken")

GameSchema.statics.unstarted = (done) ->
  @model("Game").find({ state: "unstarted" }).sort("-createdAt").lean().exec done

GameSchema.methods.checkGameover = (done) ->
  game = this
  
  game.questStats (questStats) ->
    gameover = (winnerType) ->
      game.state = "#{winnerType}_won"
      game.save (err, game) ->
        return console.error err if err
        
        done
          isGameover: true
          questStats: questStats
          game: game
    
    if questStats.numSucceeded >= NUM_QUESTS_TO_WIN
      gameover "good"
    else if questStats.numFailed >= NUM_QUESTS_TO_WIN
      gameover "bad"
    else
      done
        isGameover: false
        questStats: questStats
        game: game

GameSchema.methods.questStats = (done) ->
  game = this
  
  game.model("Quest").count { game: game, state: "succeeded" }, (err, numSucceeded) ->
    game.model("Quest").count { game: game, state: "failed" }, (err, numFailed) ->
      done { numSucceeded: numSucceeded, numFailed: numFailed }

GameSchema.methods.checkStartable = (done) ->
  if @players.length >= NUM_PLAYERS_TO_START
    @state = "playing"
    @save (err) ->
      return console.error err if err
      
      done true
  else
    done false

mongoose.model "Game", GameSchema

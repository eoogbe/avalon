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
  numPlayers:
    type: Number
    min: 0
    default: 0
    required: true
  createdAt:
    type: Date
    default: Date.now
    required: true

GameSchema.path("name").validate(( (name, respond) ->
  return respond true unless @isModified "name"

  @model("Game").count { name: name }, (err, numGames) ->
    return respond false if err
    respond numGames is 0
  ), "already taken")

GameSchema.statics.unstarted = (done) ->
  @model("Game").find { state: "unstarted" }, null, { sort: "-createdAt" }, done

GameSchema.methods.join = (done) ->
  @state = "playing"
  @numPlayers += 1
  @save done

GameSchema.methods.checkGameover = (done) ->
  NUM_QUESTS_TO_WIN = 3
  game = this
  
  game.questStats (questStats) ->
    gameover = (winnerType) ->
      game.state = "#{winnerType}_won"
      game.save (err) ->
        return console.error err if err
        done(true, questStats)
    
    if questStats.numSucceeded >= NUM_QUESTS_TO_WIN
      gameover "good"
    else if questStats.numFailed >= NUM_QUESTS_TO_WIN
      gameover "bad"
    else
      done false, questStats

GameSchema.methods.questStats = (done) ->
  game = this
  
  game.model("Quest").count { game: game, state: "succeeded" }, (err, numSucceeded) ->
    game.model("Quest").count { game: game, state: "failed" }, (err, numFailed) ->
      done { numSucceeded: numSucceeded, numFailed: numFailed }

mongoose.model "Game", GameSchema

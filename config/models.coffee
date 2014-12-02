mongoose = require "mongoose"

mongoose.connect "mongodb://localhost/avalon_dev"
mongoose.connection.on "error", ->
  console.error.bind console, "connection error:"

mongoose.Error.messages.general.required = "can't be blank"

reqModel = (filename) -> require "../app/models/#{filename}"
reqModel model for model in ["player", "game", "quest"]

module.exports =
    Player: mongoose.model "Player"
    Game: mongoose.model "Game"
    Quest: mongoose.model "Quest"

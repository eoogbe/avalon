mongoose = require "mongoose"

module.exports = (app) ->
    config = require("./environment")[app.get("env")]
    
    mongoose.connect config.databaseUri
    mongoose.connection.on "error", ->
      console.error.bind console, "connection error:"
    
    mongoose.Error.messages.general.required = "can't be blank"
    
    reqModel = (filename) -> require "../app/models/#{filename}"
    reqModel model for model in ["player", "game", "quest", "quest_vote"]

    {
        Player: mongoose.model "Player"
        Game: mongoose.model "Game"
        Quest: mongoose.model "Quest"
        QuestVote: mongoose.model "QuestVote"
    }

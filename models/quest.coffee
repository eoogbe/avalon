mongoose = require "mongoose"

QuestSchema = mongoose.Schema
    state:
        type: String
        enum: ["playing", "succeeded", "failed"]
        default: "playing"
        required: true
    game:
        type: mongoose.Schema.Types.ObjectId
        ref: "Game"
        required: true
    createdAt:
        type: Date
        default: Date.now
        required: true

mongoose.model "Quest", QuestSchema

mongoose = require "mongoose"

QuestVoteSchema = mongoose.Schema
  isApprove:
    type: Boolean
    required: true
  player:
    type: mongoose.Schema.Types.ObjectId
    ref: "Player"
    required: true
  quest:
    type: mongoose.Schema.Types.ObjectId
    ref: "Quest"
    required: true
  createdAt:
    type: Date
    default: Date.now
    required: true

mongoose.model "QuestVote", QuestVoteSchema

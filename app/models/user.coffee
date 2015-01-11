mongoose = require "mongoose"

UserSchema = mongoose.Schema
  name:
    type: String
    required: true
    unique: true
  createdAt:
    type: Date
    default: Date.now
    required: true

UserSchema.statics.upsert = (conditions, done) ->
  User = this
  
  User.findOne conditions, (err, user) ->
    if err or user
      done err, user
    else
      User.create conditions, done

mongoose.model "User", UserSchema

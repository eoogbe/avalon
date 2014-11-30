express = require "express"
app = express()
http = require("http").Server app
io = require("socket.io")(http)
logger = require "morgan"
path = require "path"
errorHandler = require "errorhandler"
less = require "less-middleware"
coffeescript = require "connect-coffee-script"
mongoose = require "mongoose"

app.set "port", process.env.PORT || 3000
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"
app.use logger "dev"
app.use less path.join(__dirname, "assets", "styles"),
  dest: path.join __dirname, "public"
  preprocess:
    path: (pathname) -> pathname.replace /\\stylesheets\\/, "\\"
app.use coffeescript
  src: path.join __dirname, "assets", "scripts"
  dest: path.join __dirname, "public", "javascripts"
  prefix: "/javascripts"
app.use express.static path.join(__dirname, "public")

mongoose.connect "mongodb://localhost/avalon_dev"
mongoose.connection.on "error", ->
  console.error.bind console, "connection error:"

mongoose.Error.messages.general.required = "can't be blank"

require "./models/game"
require "./models/quest"

Game = mongoose.model "Game"
Quest = mongoose.model "Quest"

app.get "/", (req, res) ->
  res.render "index"

app.use errorHandler() if app.get("env") is "development"

io.on "connection", (socket) ->
  showGames = ->
    Game.unstarted (err, games) ->
      return console.error err if err
      
      io.emit "show_games", games
  
  showGames()
  
  socket.on "game_created", (name) ->
    Game.create { name: name }, (err) ->
      if !err
        showGames()
      else if err.name is "ValidationError"
        io.emit "new_game_error", err.errors
      else
        console.error err
  
  socket.on "game_joined", (gameId) ->
    Game.findById gameId, (err, game) ->
      return console.error err if err
      
      game.join (err) ->
        return console.error err if err
        
        Game.unstarted (err, games) ->
          return console.error err if err
          
          io.emit "show_new_quest",
            currentGame: game
            games: games
  
  socket.on "quest_created", (data) ->
    Game.findById data.gameId, (err, game) ->
      return console.error err if err
      
      Quest.create { state: data.state, game: game }, (err, quest) ->
        return console.error err if err
        
        game.checkGameover (isGameover, questStats) ->
          if isGameover
            io.emit "show_gameover", game
          else
            io.emit "show_quest",
              quest: quest
              questStats: questStats

http.listen app.get("port"), ->
  console.log "Express server listening on port #{app.get('port')}"

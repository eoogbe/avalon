express = require "express"
app = express()
http = require("http").Server app
io = require("socket.io")(http)
logger = require "morgan"
path = require "path"
errorHandler = require "errorhandler"
less = require "less-middleware"
coffeescript = require "connect-coffee-script"

app.set "port", process.env.PORT || 3000
app.set "views", path.join(__dirname, "app", "views")
app.set "view engine", "jade"
app.use logger "dev"
app.use less path.join(__dirname, "app", "assets", "styles"),
  dest: path.join __dirname, "public"
  preprocess:
    path: (pathname) -> pathname.replace /\\stylesheets\\/, "\\"
app.use coffeescript
  src: path.join __dirname, "app", "assets", "scripts"
  dest: path.join __dirname, "public", "javascripts"
  prefix: "/javascripts"
app.use express.static path.join(__dirname, "public")

transformCamel = (str, delim, clbk) ->
  (for ch in str
    if ch.toUpperCase() isnt ch
      ch
    else if clbk?
      delim + clbk(ch)
    else
      delim + ch
  ).join ""

app.locals.capitalize = (str) -> str.charAt(0).toUpperCase() + str.slice(1)
app.locals.humanize = (str) -> app.locals.capitalize transformCamel(str, " ")
app.locals.hyphenate = (str) ->
    transformCamel str, "-", (ch) -> ch.toLowerCase()

models = require "./config/models"

app.get "/", (req, res) ->
  res.render "index"

app.use errorHandler() if app.get("env") is "development"

playerHandler = require "./app/event_handlers/player_handler"
gameHandler = require "./app/event_handlers/game_handler"
questHandler = require "./app/event_handlers/quest_handler"

io.on "connection", (socket) ->
  showGames = (player) ->
    models.Game.unstarted (err, games) ->
      return console.error err if err
      
      io.emit "show_games",
        games: games
        currentPlayer: player
  
  socket.on "player_updated", playerHandler.updated(io, models, showGames)
  socket.on "game_created", gameHandler.created(io, models)
  socket.on "game_joined", gameHandler.joined(io, models)
  socket.on "quest_created", questHandler.created(io, models)
  socket.on "gameover", gameHandler.gameover(io, models, showGames)

http.listen app.get("port"), ->
  console.log "Express server listening on port #{app.get('port')}"

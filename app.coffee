express = require "express"
app = express()
http = require("http").Server app
io = require("socket.io")(http)
logger = require "morgan"
session = require "express-session"
path = require "path"
errorHandler = require "errorhandler"
less = require "less-middleware"
coffeescript = require "connect-coffee-script"

sessionMiddleware = session
  secret: "placeholder secret"
  resave: false
  saveUninitialized: false

app.set "port", process.env.PORT || 3000
app.set "views", path.join(__dirname, "app", "views")
app.set "view engine", "jade"
app.use logger "dev"
app.use sessionMiddleware
app.use less path.join(__dirname, "app", "assets", "styles"),
  dest: path.join __dirname, "public"
  preprocess:
    path: (pathname) -> pathname.replace /\\stylesheets\\/, "\\"
app.use coffeescript
  src: path.join __dirname, "app", "assets", "scripts"
  dest: path.join __dirname, "public", "javascripts"
  prefix: "/javascripts"
app.use express.static path.join(__dirname, "public")

app.get "/", (req, res) ->
  res.render "index"

app.use errorHandler() if app.get("env") is "development"

require("./config/socket")(io, sessionMiddleware)

http.listen app.get("port"), ->
  console.log "Express server listening on port #{app.get('port')}"

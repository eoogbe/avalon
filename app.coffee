express = require "express"
app = express()
http = require("http").Server app

logger = require "morgan"
path = require "path"
coffeescript = require "connect-coffee-script"

app.set "port", process.env.PORT || 3000
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"
app.use logger "dev"
app.use coffeescript
  src: path.join __dirname, "assets"
  dest: path.join __dirname, "public"
app.use express.static path.join(__dirname, "public")

app.get "/", (req, res) ->
  res.render "index"

http.listen app.get("port"), ->
  console.log "Express server listening on port #{app.get('port')}"

express = require "express"
app = express()
http = require("http").Server app
path = require "path"

app.set "port", process.env.PORT || 3000
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"
app.use express.static path.join(__dirname, "public")

app.get "/", (req, res) ->
  res.render "index"

http.listen app.get("port"), ->
  console.log "Express server listening on port #{app.get('port')}"

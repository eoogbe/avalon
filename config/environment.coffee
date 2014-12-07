module.exports =
  production:
    redisClient: ->
      rtg = require("url").parse process.env.REDISTOGO_URL
      redis = require("redis").createClient rtg.port, rtg.hostname
      redis.auth rtg.auth.split(":")[1]
      redis
    sessionSecret: process.env.SESSION_SECRET
    databaseUri: process.env.MONGOLAB_URI
  development:
    redisClient: require("redis").createClient
    sessionSecret: "9289kv(@&v_yh5q-psx%ay6x6xv6u#ob(&h&k*mf3(nemcg+!$"
    databaseUri: "mongodb://localhost/avalon_dev"

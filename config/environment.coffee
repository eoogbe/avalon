module.exports =
  production:
    port: process.env.OPENSHIFT_NODEJS_PORT
    redisClient: ->
      redisUrl = require("url").parse process.env.REDIS_URL
      redis = require("redis").createClient redisUrl.port, redisUrl.hostname
      redis.auth process.env.REDIS_PASSWORD
      redis
    sessionSecret: process.env.SESSION_SECRET
    databaseUrl: process.env.OPENSHIFT_MONGODB_DB_URL
  development:
    port: 3000
    redisClient: require("redis").createClient
    sessionSecret: "9289kv(@&v_yh5q-psx%ay6x6xv6u#ob(&h&k*mf3(nemcg+!$"
    databaseUrl: "mongodb://localhost/avalon_dev"

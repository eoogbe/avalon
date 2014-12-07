module.exports =
  production:
    sessionSecret: process.env.SESSION_SECRET
    databaseUri: process.env.MONGOLAB_URI
  development:
    sessionSecret: "9289kv(@&v_yh5q-psx%ay6x6xv6u#ob(&h&k*mf3(nemcg+!$"
    databaseUri: "mongodb://localhost/avalon_dev"

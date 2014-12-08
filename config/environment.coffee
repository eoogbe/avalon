module.exports =
  production:
    port: process.env.OPENSHIFT_NODEJS_PORT
    ip: process.env.OPENSHIFT_NODEJS_IP
    sessionSecret: process.env.SESSION_SECRET
    databaseUrl: process.env.OPENSHIFT_MONGODB_DB_URL
  development:
    port: 3000
    ip: "127.0.0.1"
    sessionSecret: "9289kv(@&v_yh5q-psx%ay6x6xv6u#ob(&h&k*mf3(nemcg+!$"
    databaseUrl: "mongodb://localhost/avalon_dev"

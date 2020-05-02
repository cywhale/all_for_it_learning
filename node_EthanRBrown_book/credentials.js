const env = process.env.NODE_ENV || "development"
const credentials = require(`./.credentials.${env}`)

module.exports = {
  credentials,
  pg_credi: credentials.postgres,
  cookieSec: credentials.cookieSecret,
}


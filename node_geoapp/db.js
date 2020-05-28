const { credentials } = require('./credentials')

// initialize database connection
const mongoose = require('mongoose')
const env = process.env.NODE_ENV || "development"

let dbname = "testgeo"
const options = {
  dbName: dbname, 
  keepAlive: 1,
  useUnifiedTopology: true,
  useNewUrlParser: true,
  useFindAndModify: false,
  useCreateIndex: true,
};

const { connectionString } = credentials.mongo //[env]
if(!connectionString) {
  console.error('MongoDB connection string missing!')
  process.exit(1)
}

mongoose.connect(connectionString, options) //+ '/' + dbname
mongoose.Promise = global.Promise

const db = mongoose.connection //.useDB(dbname)
db.on('error', err => {
  console.error('MongoDB error: ' + err.message)
  process.exit(1)
})
db.once('open', () => console.log('MongoDB connection established'))

module.exports.mongooseConn = db


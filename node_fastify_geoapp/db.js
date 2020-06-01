//const fastify = require('fastify')();
const fastifyPlugin = require('fastify-plugin')
const { credentials } = require('./credentials')

// initialize database connection
const mongoose = require('mongoose')
const env = process.env.NODE_ENV || "development"
const dbname = "testgeo" //"layercollection" is a collection under testgeo

const db_options = {
  dbName: dbname,
  useUnifiedTopology: true,
  useNewUrlParser: true,
  useCreateIndex: true,
};

const { connectionString } = credentials.mongo //[env]
if(!connectionString) {
  console.error('MongoDB connection string missing!')
  process.exit(1)
}

// Connect to DB
async function dbConnector(fastify) {
    try {
        console.log(connectionString)
        console.log(db_options.dbName)
        const db = await mongoose
            .connect(connectionString, db_options)
        console.log("Database is connected")
        fastify.decorate('mongo', db) 
    } catch (err) {
        console.log(err)
    }
}

module.exports = fastifyPlugin(dbConnector)

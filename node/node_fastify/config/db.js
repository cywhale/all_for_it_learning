const fastifyPlugin = require('fastify-plugin')
const { credentials } = require('../credentials')
const mongoose = require('mongoose')
const env = process.env.NODE_ENV || "development"
const { connectionString } = credentials.mongo 
if(!connectionString) {
  console.error('MongoDB connection string missing!')
  process.exit(1)
}

// Connect to DB
async function dbConnector(fastify, options) {
    try {
        //const url = connectionString
        const db = await mongoose
            .connect(connectionString, {
                useNewUrlParser: true
            })
        console.log("Database is connected")
        fastify.decorate('mongo', db)
        //if (!fastify.mongoose) {
        //  fastify.decorate('mongoose')
        //}
        //next()
    } catch (err) {
        console.log(err)
    }
}
module.exports = fastifyPlugin(dbConnector)

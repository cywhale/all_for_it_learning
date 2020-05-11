//source: https://codesource.io/build-a-rest-service-with-fastify/
const fastify = require('fastify'); //Bring in Fastify
const PORT = process.env.PORT || 3000;
const db = require("./config/db")
const routes = require("./routes/postRoutes");
const app = fastify({
  logger: true
})

app.register(db)
//app.use(db())

routes.forEach((route, index) => {
    app.route(route)
})

// Declare a route
app.get("/", async () => {
  return {
    Message: "Fastify is On Fire"
  }
})
//Funtion To run the server
const start = async () => {
  try {
    await app.listen(PORT)
    app.log.info(`server listening on ${app.server.address().port}`)
  } catch (err) {
    app.log.error(err)
    process.exit(1)
  }
}
start();

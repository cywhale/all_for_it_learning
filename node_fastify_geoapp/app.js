//app.js http://deneli.us/geo-crud-part1 but modified to fastify by cywhale
const fastify = require('fastify')
const PORT = process.env.PORT || 3000;
//const bodyParser = require('body-parser');
//const cookieParser = require('fastify-cookie')
//const createError = require('http-errors')
const path = require('path')
const pug = require('pug')
//const fastifySession = require('fastify-session')
//const MongoStore = require('connect-mongo')(fastifySession)
//const logger = require('morgan');
const routes = require('./routes/geo.route')
//const credentials = require('./credentials')
const db = require('./db')
//const db2 = db.mongooseConn

// initialize the fastify app
const app = fastify({
  logger: true
})

app.register(db)

//app.use(bodyParser.urlencoded({ extended: false }))
//app.use(bodyParser.json())

//app.use(cookieParser(credentials.cookieSec))
//app.use(expressSession({
//  cookieName: 'session',
//  secret: credentials.cookieSec,
//  duration: 30 * 60 * 1000,
//  activeDuration: 5 * 60 * 1000,
//  httpOnly: true,
//  secure: true,
//  ephemeral: true,
//  resave: true,
//  saveUninitialized: true,
//  store: new MongoStore({
//     mongooseConnection: db2,
//     autoReconnect:true,
//  })
//}))

// view engine setup
app.register(require('fastify-static'), {
  root: path.join(__dirname, 'public'),
  prefix: '/' // optional: default '/'
});

// view engine setup
app.register(require('point-of-view'), {
    engine: {
      pug: pug
    },
    root: path.join(__dirname, '/public/')
    //views: 'views'
});
//app.set('view engine', 'pug');

routes.forEach((route, index) => {
    app.route(route)
})

/* catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('views/error.pug');
});
*/

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


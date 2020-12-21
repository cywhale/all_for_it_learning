//app.js http://deneli.us/geo-crud-part1
//https://github.com/denelius/nodejs_leaflet
const express = require('express');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser')
const createError = require('http-errors')
const path = require('path')
const expressSession = require('express-session')
const MongoStore = require('connect-mongo')(expressSession)
const logger = require('morgan');
const geo = require('./routes/geo.route'); // Imports routes for the features

//const indexRouter = require('./routes/index');
//const usersRouter = require('./routes/users');

const credentials = require('./credentials')
const db = require('./db')
const db2 = db.mongooseConn //.useDB('test')

// initialize the express app
const app = express();

app.use(bodyParser.urlencoded({ extended: true }))
app.use(bodyParser.json())

app.use(cookieParser(credentials.cookieSec)) //credentials.cookieSecret
app.use(expressSession({
  //https://stackoverflow.com/questions/24477035/express-4-0-express-session-with-odd-warnin$
  cookieName: 'session',
  secret: credentials.cookieSec,//,
  duration: 30 * 60 * 1000,
  activeDuration: 5 * 60 * 1000,
  httpOnly: true,
  secure: true,
  ephemeral: true,
  resave: true,
  saveUninitialized: true,
  store: new MongoStore({
     mongooseConnection: db2,
     autoReconnect:true,
  })
}))

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', geo); // /geo

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});


let port = 3000;

app.listen(port, () => {
    console.log('The server is running on port number ' + port);
});

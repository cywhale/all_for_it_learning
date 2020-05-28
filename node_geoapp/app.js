//app.js http://deneli.us/geo-crud-part1
const express = require('express');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser')
const expressSession = require('express-session')
const MongoStore = require('connect-mongo')(expressSession)
const geo = require('./routes/geo.route'); // Imports routes for the features

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


app.use('/geo', geo);

let port = 3000;


app.listen(port, () => {
    console.log('The server is running on port number ' + port);
});

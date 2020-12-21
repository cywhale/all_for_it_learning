'use strict'

//v1.0.0 source: https://codesource.io/build-a-rest-service-with-fastify/
//v1.0.1 modified by cywhale, try a fastify-server with preact client
const fastify = require('fastify'); //Bring in Fastify
const fs = require('fs');
const path = require('path');
const PORT = process.env.PORT || 3000;
const db = require("./config/db")
const routes = require("./routes/postRoutes");

async function configSecServ(certDir='config') {
  const readCertFile = (filename) => {
    return fs.readFileSync(path.join(__dirname, certDir, filename));
  };
  try {
    const [key, cert] = await Promise.all(
      [readCertFile('privkey.pem'), readCertFile('fullchain.pem')]);
    return {key, cert, allowHTTP1: true};
  } catch {
    console.log("Certifite error...");
    process.exit(1)
  }
}

const startServer = async () => {

  const {key, cert, allowHTTP1} = await configSecServ();
  const app = fastify({
      http2: true,
      trustProxy: true,
      https: {key, cert, allowHTTP1},
      logger: true
  })

//https://web.dev/codelab-text-compression-brotli
  try {
    await app.get('*.js', (req, res, next) => {
      if (req.header('Accept-Encoding').includes('br')) {
        req.url = req.url + '.br';
        console.log(req.header('Accept-Encoding Brotli'));
        res.set('Content-Encoding', 'br');
        res.set('Content-Type', 'application/javascript; charset=UTF-8');
      } else {
        req.url = req.url + '.gz';
        console.log(req.header('Accept-Encoding Gzip'));
        res.set('Content-Encoding', 'gzip');
        res.set('Content-Type', 'application/javascript; charset=UTF-8');
      }
      next();
    });
  } catch {
    app.log.info('Try .br, .gz got error');
  }

  try {
    await app.register(require('fastify-static'), {
      root: path.join(__dirname, 'ui/build'),
      prefix: '/',
      prefixAvoidTrailingSlash: true,
      list: true /*{
        format: 'html',
        names: ['index', 'index.html', '/']
      }*/
    });
  } catch {
    app.log.info('Try serve ui/build error');
  }

  try {
   await app.register(db);
   //app.use(db())
  } catch {
    app.log.info('Try connect db error');
  }

  try {
    await routes.forEach((route, index) => {
      app.route(route)
    });
  } catch {
    app.log.info('Try serve each route error');
  }

/* Declare a route
app.get("/", async () => {
  return {
    Message: "Fastify is On Fire"
  }
})
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
}

startServer();

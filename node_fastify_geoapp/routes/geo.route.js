// routes/geo.route.js
//const fastify = require('fastify');
//const router = fastify();
const boom = require('boom')

// Require the controllers
const geo_controller = require('../controllers/geo.controller');

const routes = [{
    method: 'GET',
    url: '/test',
    handler: geo_controller.test
  },
  {
    method: 'POST',
    url: '/create',
    handler: geo_controller.geo_create
  },
  {
    method: 'GET',
    url: '/read_geos',
    handler: geo_controller.geo_list
  },
  { // localhost:3000/geo/read_name/CREATETEST
    method: 'GET',
    url: '/read_name/:name',
    handler: geo_controller.geo_name
  },
  { // localhost:3000/geo/read_id/<id>
    method: 'GET',
    url: '/read_id/:id',
    handler: geo_controller.geo_id
  },
  { // localhost:3000/geo/read_allnames
    method: 'GET',
    url: '/read_allnames',
    handler: geo_controller.geo_allnames
  },
  { // localhost:3000/geo/read_all
    method: 'GET',
    url: '/read_all',
    handler: geo_controller.geo_all
  },
  { /* UPDATE */
    method: 'PUT',
    url: '/update/:id',
    handler: geo_controller.feature_update
  }, //localhost:3000/features/update/<featureid>
     //BODY {"geometry":{"coordinates":[[-34.44379,-70.65775],[-34.199626,-71.106262],[-34.04576,-71.61748]]}}
  {  /* DELETE */
    method: 'DELETE',
    url: '/delete/:id',
    handler: geo_controller.geo_delete
  }, //localhost:3000/geo/delete/<featureid>
  {  /* GET home page. */
    method: 'GET',
    url: '/',
    handler: geo_controller.rootx
  },
  { /* GET Map page. */
    method: 'GET',
    url: '/map',
    handler: geo_controller.map
  }
]
module.exports = routes

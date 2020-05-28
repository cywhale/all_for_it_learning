// routes/geo.route.js
const express = require('express');
const router = express.Router();

// Require the controllers
const geo_controller = require('../controllers/geo.controller');

// test url.
router.get('/test', geo_controller.test);

router.post('/create', geo_controller.geo_create);

router.get('/read_geos', geo_controller.geo_list);

router.get('/read_name/:name', geo_controller.geo_name);
// localhost:3000/geo/read_name/CREATETEST

router.get('/read_id/:id', geo_controller.geo_id);
// localhost:3000/geo/read_id/<id>

router.get('/read_allnames', geo_controller.geo_allnames);
// localhost:3000/geo/read_allnames

router.get('/read_all', geo_controller.geo_all);
// localhost:3000/geo/read_all

/* UPDATE */
router.put('/update/:id', geo_controller.feature_update);
//localhost:3000/features/update/<featureid>
//BODY {"geometry":{"coordinates":[[-34.44379,-70.65775],[-34.199626,-71.106262],[-34.04576,-71.61748]]}}

/* DELETE */
router.delete('/delete/:id', geo_controller.geo_delete);
//localhost:3000/geo/delete/<featureid>

module.exports = router;

// controllers/geo.controller.js
const boom = require('boom')
const Geo = require('../models/geo.model');
const jlayer = Geo.jlayer

exports.test = async (req, res) => {
    res.send('hello test controller!');
};

exports.rootx = async (req, res) => {
    res.view('../views/root.pug', { title: 'Map' });
    return res; //https://github.com/fastify/point-of-view/issues/144 see ans: point-of-view/example-async.js Line 26 
};

exports.map = async (req,res) => {
  try {
    //let jgeo = 
    await Geo.find({},{}, function(e, geo) {
      //let jcol = await 
      //jlayer.find({},{}, function(e2, jcol) {
      //let geo = [...jgeo, ...jcol]; //Object.assign({},jgeo, jcol);
      //console.log(geo);
        res.view('../views/map.pug', {
          "jmap" : geo,
          lat : 40.78854,
          lng : -73.96374
        }); // see aboving ans for err: Promise not fulfilled when using res.view #144
      //});
    });
    return res;
  } catch (err) {
    throw boom.boomify(err)
  }
};

/* CREATE */
exports.geo_create = async (req, res) => { //req, res, next
    try {
      let geo = new Geo( req.body )
      await geo.save() /* function (err) {
        if (err) {
            return next(err);
        } */
      res.send('Feature created successfully')
      //})
    } catch (err) {
      throw boom.boomify(err)
    }
};


// Use Async.parallel: Read Multiple Collections from MongoDB without Callback Hell
// https://bit.ly/2yO9Ala another solution:
// https://stackoverflow.com/questions/46029399/how-to-use-async-parallel-for-multiple-queries/46029595

/* READ */
// return list of all geometry
exports.geo_list = async (req, res) => {
   try {

     let jgeo = await Geo.find({}, {'geometry': 1}); //, function (err, geo) {
        //if (err) return next(err);
        //jdt.geos = geo;

     let jcol = await jlayer.find({}, {'geometry': 1}); //, function (err2, geo2) {
         //if (err2) return next(err2);
         //jdt.jcol = geo2;
         //res.json(jdt)
       //}
     let results = [...jgeo, ...jcol];
     // console.log(results);
     return results; //res.json
     //});
  } catch (err) {
    throw boom.boomify(err)
  }
};

//return item that matches name
exports.geo_name = async (req, res) => {
  try {

    let jgeo = await Geo.findOne({ name: req.params.name },{});
    //let jcol = await jlayer.findOne({ name: req.params.name },{});
    //let results = [jgeo, jcol];
    return jgeo; //results;
    //})
  } catch (err) {
    throw boom.boomify(err)
  }
};

//return item that matches id
exports.geo_id = async (req, res) => {
  try {
     let jgeo = await Geo.findById(req.params.id);
     //let results = Promise.all(
     //jgeo.map( jdt => 
     let jcol = await jlayer.findById(req.params.id);
     let results = [...jgeo, ...jcol];
     //console.log(results);
     return results; //res.json
  } catch (err) {
    throw boom.boomify(err)
  }
};

//return all names only
exports.geo_allnames = async (req, res) => {
  try {

    let jgeo = await Geo.find({},{'name': 1});
    let jcol = await jlayer.find({},{'name': 1});
    let results = [...jgeo, ...jcol];
    return results; //res.json
    //});
  } catch (err) {
    throw boom.boomify(err)
  }
};

//return geometry only
exports.geo_all = async (req,res) => {
  try {
     let jgeo = await Geo.find({},{});
     let jcol = await jlayer.find({},{});
     let results = [...jgeo, ...jcol];
     return results; //res.json
  } catch (err) {
    throw boom.boomify(err)
  }
};

/* UPDATE */
exports.feature_update = async (req, res) => {
  try {
    await Geo.findByIdAndUpdate(req.params.id, {$set: req.body});
    res.send('Geometry updated.');
  } catch (err) {
    throw boom.boomify(err)
  }
};

/* DELETE */
exports.geo_delete = async (req, res) => {
  try {
    await Geo.findByIdAndRemove(req.params.id);
    res.send('Deleted successfully!');
  } catch (err) {
    throw boom.boomify(err)
  }
};


// controllers/geo.controller.js
const Geo = require('../models/geo.model');
const jlayer = Geo.jlayer

//Simple version, without validation or sanitation
exports.test = function (req, res) {
    res.send('hello test controller!');
};


/* CREATE */
exports.geo_create = function (req, res, next) {
    var geo = new Geo(
        req.body
    );

    geo.save(function (err) {
        if (err) {
            return next(err);
        }
        res.send('Feature created successfully')
    })
}

// Use Async.parallel: Read Multiple Collections from MongoDB without Callback Hell
// https://bit.ly/2yO9Ala

/* READ */
// return list of all geometry
exports.geo_list = function (req, res) {
   var jdt = {};

   Geo.find({},{'geometry': 1}, function (err, geo) {
        if (err) return next(err);

        jdt.geos = geo;

        jlayer.find({},{'geometry': 1}, function (err2, geo2) {
            if (err2) return next(err2);

            jdt.jcol = geo2;
            res.json(jdt)
        });
    });
};

//return item that matches name
exports.geo_name = function (req, res) {
    //var jdt = {};

    Geo.findOne({ name: req.params.name },{}, function (err, geo) {
        if (err) return next(err);

        //jdt.geos = geo;

        //jlayer.findOnne({ name: req.params.name },{}, function (err2, geo2) {
        //    if (err2) return next(err2);

        //    jdt.jcol = geo2;
        //    res.send(jdt)
        //});
        res.send(geo);
    })
};

//return item that matches id
exports.geo_id = function (req, res) {
    var jdt = {};

    Geo.findById(req.params.id, function (err, geo) {
        if (err) return next(err);

        jdt.geos = geo;

        jlayer.findById(req.params.id, function (err2, geo2) {
            if (err2) return next(err2);

            jdt.jcol = geo2;
            res.send(jdt)
        });
        //res.send(geo);
    })
};

//return all names only
exports.geo_allnames = function (req, res) {
    //var jdt = {};

    Geo.find({},{'name': 1}, function (err, geo) {
        if (err) return next(err);

        //jdt.geos = geo;

        //jlayer.find({},{'name': 1}, function (err2, geo2) {
        //    if (err2) return next(err2);

        //    jdt.jcol = geo2;
        //    res.send(jdt)
        //});
        res.json(geo);
    });
};

//return geometry only
exports.geo_all = function(req,res) {
    var jdt = {};
    Geo.find({},{}, function(err, geo){
        if (err) return next(err);

        jdt.geos = geo;

        jlayer.find({},{}, function (err2, geo2) {
            if (err2) return next(err2);

            jdt.jcol = geo2;
            res.send(jdt)
        });
        //res.send(geo)
    });
};

/* UPDATE */
exports.feature_update = function (req, res, next) {
    Geo.findByIdAndUpdate(req.params.id, {$set: req.body}, function (err, geo) {
        if (err) return next(err);
        res.send('Geometry updated.');
    });
};

/* DELETE */
exports.geo_delete = function (req, res) {
    Geo.findByIdAndRemove(req.params.id, function (err) {
        if (err) return next(err);
        res.send('Deleted successfully!');
    })
};


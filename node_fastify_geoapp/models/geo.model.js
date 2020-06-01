// models/geo.model.js
const mongoose = require('mongoose');

let GeoSchema = new mongoose.Schema({
  type: String,
  name: String,
  style: {
    color: String,
    weight: Number,
    opacity: Number
  },
  geometry: {
    type: {
      type: String,
      enum: ['LineString'],
      required: true
    },
    coordinates: {
      type: Array,
      index: '2d'
    }
  },
  properties: {
    direction: String,
    power: Number
  }
});

let layerSchema = new mongoose.Schema({
    name: String,
    type: mongoose.Schema.Types.Mixed
});

const jLayer = mongoose.model('jLayer', layerSchema, 'layercollection')
module.exports.jlayer = jLayer
module.exports = mongoose.model('Geo', GeoSchema)

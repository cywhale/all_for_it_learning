// models/geo.model.js
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

let GeoSchema = new Schema({
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

let layerSchema = new Schema({
    name: String,
    type: Schema.Types.Mixed
});

const Geo = mongoose.model('Geo', GeoSchema)
module.exports = Geo

const jLayer = mongoose.model('jLayer', layerSchema, 'layercollection')
module.exports.jlayer = jLayer

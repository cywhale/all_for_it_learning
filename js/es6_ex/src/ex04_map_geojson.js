const geo1 = {
    "type":"FeatureCollection",
    "features":[{
        "type":"Feature",
        "properties":{"id":47773},
        "geometry":{
            "type":"LineString",
            "coordinates":[[121.27,22.52],[121.62,22.713],[121.75,22.785],[124.11,27.06]
        ]}}, {
        "type":"Feature",
        "properties":{"id":47802},
        "geometry":{
            "type":"LineString",
            "coordinates":[[121.27,22.53],[122.772,22.569],[120.326,19.937]
        ]}}
    ]};

function coordTo3d(coords, sphere_radius, z_is_height = false) {
    const lambda = coords[0] * Math.PI / 180;
    const phi = coords[1] * Math.PI / 180;
    let radius = sphere_radius;
    if (z_is_height) {
        radius = coords[2] + sphere_radius;
    }
    let rphi = Math.cos(phi) * radius;
    let out = [
        Math.cos(lambda) * rphi,
        Math.sin(phi) * radius,
        -1.0 * Math.sin(lambda) * rphi
    ];
    return out;
}

geoline2Path = function(geojson) {
    return geojson.features.map(function(feature) {
        return feature.geometry.coordinates.map(function(coord) {
            return [parseFloat(coord[1]), parseFloat(coord[0])];
        });
    });
};
// Only return coordinates, but fail to return {{id: [coordinates]}, {...}}
let o1 = geoline2Path(geo1);
console.log(o1);

var gid = geo1.features.map(function(feature) { return feature.properties.id; });
let gidx = [...gid.keys()];
console.log(gid);

var o2 = o1.map((x) => { 
    return x.map((coord) => {
        return coordTo3d(coord, sphere_radius = 10, z_is_height = false);
    }); 
});
console.log(o2[0]);
console.log(o2[1]);

//let geo2 = gidx.map((obj, i) => Object.assign({}, obj, 
//   {id: gid[i], coords: [...o2[i]]}));

let geo2 = gid.reduce((obj, x, i) => 
      Object.assign({}, obj, {[x]: [...o2[i]]}), {});
console.log(geo2);
// console.log(Object.keys(geo2))
// console.log(Object.values(geo2))
// if all keys the same ({id: , coords:}, cannot use Object.assign, will be merged, not concat)
// Next if has density return {id: , density: coord[2], to3d: cood_array after coordTo3d}

let geox = {};
gidx.forEach((i) => {
   console.log(i);
   //geox[gid[i]] = [...o2[i]]; //then geox will equal geo2
   geox[i] = {id: gid[i], coords: [...o2[i]]};
});

console.log(geox);
console.log(geox[1].coords)

// so another version to return {id: ,coords: }
geolinexPath = function(geojson) {
    //const destruct = (obj, ...keys) =>
    //    keys.reduce((a, c) => ({ ...a, [c]: obj[c] }), {});
    //const [...obj] =
    return geojson.features.map(function(feature) {
        let id = feature.properties.id? feature.properties.id: feature.properties.NAME;
        let ct = feature.geometry.coordinates.map(function(coord) {
            return [parseFloat(coord[1]), parseFloat(coord[0])];
        });
        let dt = { id: [id], coords: [...ct] };
        return dt;
    });
    //return obj; //destruct(obj, 'id', 'coords');
};
let o3 = geolinexPath(geo1);
console.log(o3);
console.log(o3[1].coords);

let coords = o3[1].coords.slice();
let tmpc = coords.slice().reverse();
let newc = [].concat(coords, tmpc);
console.log(newc);

console.log("Convert geojson point")

const ptgeo1 = {"features": [
    {"geometry": {"coordinates": [122.208, 25.4158], "type": "Point"}, "properties": {"id": 0, "inLine": 1, "name": "4789"}, "type": "Feature"}, 
    {"geometry": {"coordinates": [122.677, 25.249], "type": "Point"}, "properties": {"id": 1, "inLine": 1, "name": "4790"}, "type": "Feature"}, 
    {"geometry": {"coordinates": [123.1503, 25.0818], "type": "Point"}, "properties": {"id": 2, "inLine": 1, "name": "4791"}, "type": "Feature"}, 
    {"geometry": {"coordinates": [121.4918, 25.6639], "type": "Point"}, "properties": {"id": 3, "inLine": 1, "name": "4792"}, "type": "Feature"}, 
    {"geometry": {"coordinates": [120.776, 25.9018], "type": "Point"}, "properties": {"id": 4, "inLine": 1, "name": "4793"}, "type": "Feature"}, 
    {"geometry": {"coordinates": [120.1021, 26.1913], "type": "Point"}, "properties": {"id": 5, "inLine": 1, "name": "4794"}, "type": "Feature"},
    {"geometry": {"coordinates": [121.7322, 26.6148], "type": "Point"}, "properties": {"id": 33, "inLine": 1, "name": "4822"}, "type": "Feature"}], 
    "type": "FeatureCollection", 
    "crs": {"properties": {"name": "EPSG:4326"}, "type": "name"}, "cPlanInfo": {"proj_name": "", "work_dock_chk": false, "specialNeed": "", "datetime_dep": "2019-09-18 10:00", "bigItems": "", "rv": 2}
};
geojson2Point = function(geojson) {
    return geojson.features.map(function(feature) {
      let coord = feature.geometry.coordinates;
      let id = feature.properties.name; 
      let dt = { id: [id], coords: [parseFloat(coord[1]), parseFloat(coord[0])] };
      return dt;
    });
};
console.log(geojson2Point(ptgeo1));

geoMultiPoly = function(geojson) {
    console.log(geojson.features.length);
    return geojson.features.map(function(feature) {
        let id = feature.properties.id? feature.properties.id: feature.properties.NAME;
        let ct = feature.geometry.coordinates.map(function(coordarr) {
          return coordarr.map(function(coords) { 
            return coords.map(function(coord) {
              return [parseFloat(coord[1]), parseFloat(coord[0])];
            });
          });
        });
        let dt = { id: [id], coords: [...ct] };
        return dt;
    });
    //return obj; //destruct(obj, 'id', 'coords');
};

let geo3 = {
    "type":"FeatureCollection",
    "features":[{"type":"Feature","properties":{
        "NAME":"TEST03"},
        "geometry":{"type":"MultiPolygon","coordinates":[[[[121.8512,24.6288],[121.8529,24.6258],[121.851,24.6243]],[[121.8527,24.6166],[121.8527,24.6167],[121.8527,24.6166]]]]}},
    {"type":"Feature","properties":{
        "NAME":"TEST03b"},
        "geometry":{"type":"MultiPolygon","coordinates":[[[[121.3074,23.2082
    ],[121.3077,23.2082],[121.3077,23.2082],[121.8512,24.6288]],[[121.3078,23.2083],[121.5999,24.9029],[121.5999,24.9031],[121.6016,24.9032]]]]}}]
}
let o4 = geoMultiPoly(geo3);
console.log(o4)
console.log(o4[1].coords);
console.log(o4[1].coords[0][0]);
console.log(o4[1].coords[0][1]);


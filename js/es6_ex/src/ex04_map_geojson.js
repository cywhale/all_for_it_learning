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
        let id = feature.properties.id;
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
console.log(o3[1].coords)

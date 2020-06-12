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

geoline2Path = function(geojson) {
    //const destruct = (obj, ...keys) =>
    //    keys.reduce((a, c) => ({ ...a, [c]: obj[c] }), {});
    //const [...obj] =
    return geojson.features.map(function(feature) {
        //let id = feature.properties.id;
        //let ct =
        return feature.geometry.coordinates.map(function(coord) {
            return [parseFloat(coord[1]), parseFloat(coord[0])];
        });
        //let dt = {[id]: [...ct]}; // { id: [id], coords: [...ct] };
        //console.log(dt);
        //return dt;
    });
    //return obj; //destruct(obj, 'id', 'coords');
};
// Only return coordinates, but fail to return {{id: [coordinates]}, {...}}
let o1 = geoline2Path(geo1);
console.log(o1);

// first node app.js under /all_for_it_learning/node_geoapp
import fetch from 'node-fetch';
//import * as definex from 
import when from './includes/cesium_when.js';
//const csWhen = new definex()

//function readnames() { 
const readnames = () =>
  //return 
  fetch('http://localhost:3000/read_allnames', {
    headers: {
      Accept: 'application/json'
    }
  })
    .then(res => res.json())
    .then(data => Object.values(data).map(item => item.name))
//}

//readnames().then(data => console.log(data))
//[ 'CREATETEST', 'lines', 'polygons', 'points' ]

const loaddata = async () => {
  let data = await readnames()
  return data
}

const mapNodes = ['1st: ', '2nd: ', '3rd: ', '4th: ']

const mapTest = (x, data, idx) => {
  return x + data[idx];
}

let promises = mapNodes.map((x, idx) => {
  console.log(idx)
  return when(loaddata(), function (data) {
    return mapTest(x, data, idx);
  });
});

//let promise = 
let promise = when.all(promises).then(function (mapResult) {
  return (mapResult)
});

promise.then(result => { console.log(result) })

/* equivalent */
let proa = mapNodes.map(async (x, idx) => {
  let data = await loaddata()
  return mapTest(x, data, idx);
});

let proz = Promise.all(proa)
  .then(result => {
    console.log("Final data: ", result);
  });


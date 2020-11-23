// Faster async functions and promises
// https://v8.dev/blog/fast-async
class Sleep {
  constructor(timeout) {
    this.timeout = timeout;
  }
  then(resolve, reject) {
    const startTime = Date.now();
    setTimeout(() => resolve(Date.now() - startTime),
               this.timeout);
  }
}

(async () => {
  const actualTime = await new Sleep(1000);
  console.log(actualTime);
})();


// first node app.js under /all_for_it_learning/node_geoapp
// npm i node-fetch async --save
const fetch = require("node-fetch");
async = require('async');

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

readnames().then(data => console.log(data))
//[ 'CREATETEST', 'lines', 'polygons', 'points' ]

/*
async.waterfall([
  readnames,
  renderView,
  setPageContents
], (err, html) => {
  if (err) {
    return console.error(err)
  }
  console.log('Successfullly change page!')
})
*/
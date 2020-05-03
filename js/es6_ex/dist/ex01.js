'use strict';

var _slicedToArray = function () { function sliceIterator(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"]) _i["return"](); } finally { if (_d) throw _e; } } return _arr; } return function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { return sliceIterator(arr, i); } else { throw new TypeError("Invalid attempt to destructure non-iterable instance"); } }; }();

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

// arrow function is not the same as anonymous func
function puz() {
  return function () {
    console.log(arguments); //closure, within its own scope 
  };
}

function puz_ar() {
  var _arguments = arguments;

  return function () {
    return console.log(_arguments);
  }; //NOT a closure, within puz_ar scope
}

puz('a', 'b')(1, 2, 3); // print 1,2,3
puz_ar('a', 'b')(1, 2, 3); // print a,b

var objl = [1, 2, 3].map(function (value) {
  return { number: value };
}); //implicitly return obj literals by ()
console.log(objl); // return three obj, each with value 1, 2, 3

//console.log(
var objt = [1, 2, 3, 4].map(function (value) {
  return value * 2;
}).filter(function (value) {
  return value > 2;
})
//) // if assign to a var then no the following error? why?
.forEach(function (value) {
  return console.log(value);
}) //why error?? Cannot read property '4' of undefined
// NOW I know, should be ; before [, that the JS builder not automatically do for you https://bit.ly/2WkNa2B
;[1, 2, 3, 4].map(function (value) {
  return value * 2;
}).filter(function (value) {
  return value > 2;
}).forEach(function (value) {
  return console.log(value);
});

// obj literals is us {} to simplify to declare a obj key:value
var g1 = {
  id: 'banana',
  name: 'BB',
  price: 10,
  currency: 'USD',
  produce: {
    year: 2010,
    month: 10,
    day: 12
  }
};

var id = g1.id; // var id = g1.id

console.log(id);

var abbrevCode = g1.id; //alias, var abbrevCode = g1.id

console.log(abbrevCode);

var dayProduce = g1.produce.day;

console.log(dayProduce); // alias in nested attribute

// cannot do this Destructuring assignment. Why?
//var { quality: { size: 'medium' } } = g1 // vsmmp
//console.log(quality) // assign not-existed attribute

var g1s = _defineProperty({}, g1.id, g1);

var sell = 'seven';
g1[sell] = {
  discount: 0.5,
  price: 15,
  customer: ['normal', 'vip']
};

var _g1$sell$customer = _slicedToArray(g1[sell].customer, 2),
    char1 = _g1$sell$customer[0],
    char2 = _g1$sell$customer[1]; //Array Destructuring 


console.log(char1); // so it's just a convenient way to assign each time for char1, char2
console.log(char2); //swap by array destructuring
var _ref = [char2, char1];
char1 = _ref[0];
char2 = _ref[1];
console.log(char1);
console.log(char2);
console.log("ori obj:", g1s);
console.log(g1s.banana);
console.log("g1[sell]: ", g1[sell]);
console.log("g1[].price", g1[sell].price);
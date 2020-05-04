// arrow, object literals, destructuring assignment
// arrow function is not the same as anonymous func
function puz() {
  return function () {
    console.log(arguments) //closure, within its own scope 
  }
}

function puz_ar() {
  return () => console.log(arguments) //NOT a closure, within puz_ar scope
}

puz('a', 'b')(1,2,3) // print 1,2,3
puz_ar('a', 'b')(1,2,3) // print a,b

var objl = [1, 2, 3].map(value => ({ number: value })) //implicitly return obj literals by ()
console.log(objl) // return three obj, each with value 1, 2, 3

//console.log(
var objt = [1, 2, 3, 4]
  .map(value => value * 2)
  .filter(value => value > 2)
//) // if assign to a var then no the following error? why?
  .forEach(value => console.log(value)) //why error?? Cannot read property '4' of undefined
// NOW I know, should be ; before [, that the JS builder not automatically do for you https://bit.ly/2WkNa2B
;[1, 2, 3, 4]
  .map(value => value * 2)
  .filter(value => value > 2)
  .forEach(value => console.log(value)) 

// obj literals is use {} to simplify to declare a obj key:value
var g1  = {
  id: 'banana',
  name: 'BB',
  price: 15,
  currency: 'USD',
  produce: {
    year: 2010,
    month: 10,
    day: 12
  }
}

var { id } = g1 // var id = g1.id
console.log(id)

var { id: abbrevCode } = g1 //alias, var abbrevCode = g1.id
console.log(abbrevCode)

var { produce: { day: dayProduce } } = g1
console.log(dayProduce) // alias in nested attribute

// Cannot do this Destructuring assignment. Why?
// var { quality: { size: 'medium' } } = g1 // vsmmp
// console.log(quality) // assign not-existed attribute

var g1s = {
  [g1.id]: g1
}
console.log(g1s.banana)

var sell = 'seven'
g1[sell] = {
  discount: 0.5,
  price: 12,
  customer: ['normal', 'vip'],
}
console.log("g1[].price", g1[sell].price)

var [char1, char2] = g1[sell].customer //Array Destructuring 
console.log(char1) // so it's just a convenient way to assign each time for char1, char2
console.log(char2)

;[char1, char2] = [char2, char1] //swap by array destructuring
console.log(char1) 
console.log(char2)

//Destructuring objects as function parameters
var getGoodSell = ({ produce, price  = 10, discount = 0.9 }) => ({
  pdate: produce.year + '/' + produce.month + '/' + produce.day,
  sell: price *  discount
})

console.log(getGoodSell(g1).pdate)
console.log(getGoodSell(g1).sell)
console.log(getGoodSell({produce: {year: 2002, month: 11, day: 13}, price: g1[sell].price}))

function splitDate(date) {
  var rdate = /(\d+).(\d+).(\d+)/
  return rdate.exec(date) 
}

var [d0, year, month, day] = splitDate(getGoodSell(g1).pdate) //the first is reserved for original input
console.log(d0)
console.log(year)
console.log(month)
console.log(day)

//spread operator ...
var sumall = (...num) => num.reduce((total, next) => total + next )
console.log(sumall(1,2,5))

var cast = (...args) => [...args]
console.log(cast('a','b','ddd'))
var cast_hx = (pre = 'first', pos = 'last', ...args) => [pre, ...args, pos]
console.log(cast_hx(pre = '1', pos = '0', 'a','b','ddd')) 
console.log([...cast_hx(pre = '1', pos = '0', 'a','b','ddd').join("")]) //expand with each character

// spread op use as fn apply
var multiply = (l, r) => l * r
console.log(multiply(...[2, 3]))

var d0 = new Date(...[2013, 3, 5]) //otherwise new (Date.bind.apply(Date, [null, 2013, 3,5]))
console.log(d0)






// ex02: template literal; Hoisting (var up to its top of current scope), let, const...
var name = 'Sha'
var emoj = 'happy'
var txt1 = `I'm ${ name }. I'm ${ emoj }`
console.log(txt1)

var tagx = (parts, ...val) => parts.reduce(
    (all, part, index) => all + val[index - 1].toUpperCase() + part
)
console.log(tagx`I'm ${ name }. I'm ${ emoj }`)

// var can be accessed within the same function scope
// but const, let can only be accessed within block {}, loop
const items = ['a', 'b', 'c']
function chkx(items) {
    return { check: () => items.shift() }
}

const todo = chkx(items)
todo.check()
console.log(items) //[ 'b', 'c' ]
//items = ['d', 'e'] // typeerror: assignment to constant variable
items.push('xxx') // const means ref cannot be modified, but its value can be modified by ref.
todo.check() 
console.log(items) //[ 'c', 'xxx' ]

let itemx = ['xa', 'xb', 'xc']
let todox = chkx(itemx)
todox.check()
console.log(itemx) //[ 'xb', 'xc' ]
itemx = ['xd', 'xe']
todox.check() // no affects to itemx because todox had bee defined by old value
console.log(itemx) //[ 'xd', 'xe' ]
chkx(itemx).check()
console.log(itemx) //[ 'xe' ] //value modified!


var readline=require('readline')
var fs=require('fs')

console.log("{'journal':[")

var rl = readline.createInterface({
      input : fs.createReadStream('/home/puffjay/Muddle.txt'),
      output: process.stdout,
      terminal: false
})

var buffer = undefined

rl.on('line',function(line){
    var myRE = /[MTWFS][ouehra][neduit] [JFMASOND][aepuco][nbrylgptvc] {1,2}[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2} [A-Z]{3} [0-9]{4}/ ///^Mon |^Tue.*|^Wed.* /  
    myRE = /^[A-Z][a-z][a-z] [A-Z][a-z][a-z] {1,2}[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2} [A-Z]{3} [0-9]{4}$/
	
    var result = line.match(myRE)
    if (result!==null) {
	if (typeof buffer !== 'undefined') {
	    console.log("'content':'"+buffer+"'},")
	    buffer='' //reset buffer
	}
    console.log("{'date':'"+(result[0]).trim()+"'")
    }
    if (result===null) {
	buffer+=line+'\n'
    }
})

rl.on('close',function() {
if (typeof buffer !== 'undefined') {
    console.log("'content':'"+buffer+"'}")
}
console.log("] }")
})


var fs=require('fs')

console.log('\\documentclass{article}')
console.log('\\usepackage{graphicx}')
console.log('')
console.log('\\begin{document}')
console.log('')
console.log('\\title{Introduction to \\LaTeX{}}')
console.log('\\author{Author\'s Name}')
console.log('')
console.log('\\maketitle')
console.log('')
console.log('\\begin{abstract}')
console.log('The abstract text goes here.')
console.log('\\end{abstract}')

//json format
// {"journal":[ 
//     {
// 	"date":"somedate",
// 	"content":"",
// 	"links":[
// 	    {
// 		"link":"",
// 		"description":""
// 	    },
// 	    {
// 		"link":"",
// 		"description":""
// 	    }
// 	]
//     },
//     {
// 	another object
//     }
// }



var filename='/home/puffjay/Muddle.txt'
if (typeof process.argv[2] !== 'undefined') {
    filename=process.argv[2]
}
var contents=fs.readFileSync(filename)

//if teh file doesn't parse, then it proly isn't valid json.
var parsedFile=JSON.parse(contents)

parsedFile.journal.forEach(function(element,index,fullArray){
    console.log('\\section{'+element.date+'}')
    //console.log(element.content)
    //console.log((element.content).replace(/\n/g,'  ')) // this is the newline control charaacter
    //console.log((element.content).replace(/\\n/g,'  ')) //this is the textual \n string beign replaced

    var splitContent=element.content.split('\\n')
    splitContent.forEach(function(element,index,fullArray){
    	//	console.log(element.replace(/&/g,'\&'))//this is the inner element, not the exterior one!

    	//troublesome text : &, multiple consecutive underscores, #,%, some ?followed by text
    	//	if (element.length>0){
    	if (element.indexOf('&')>0 
    	    || element.indexOf('#')>0 
	  //  || element.search(/\?[a-zA-Z]?/)>0 //simple test,
    	    || element.search(/_+/)!== -1 
    	    || element.indexOf('%')>0  ){
    	    console.log('phail-----------')//+element.replace(/\&/g,'\&'))
    	} else {
    	    console.log(element)
    	}

//damnit this doesn't take into account if the followings line is a url. in that case we don't want to start a new paragraph
	if (element.search(/^http/)!==-1){
   	    console.log('\\\\*') //start newline but not new paragraph	 
	}else {
	    console.log('\n') //add newline so tex puts on separate line.
	}
    	//	}
    })

    if (1===0  //PREVENT EXECUTION!!!!!!!!!!!!!!!!!
	&& element.links.length>0){
	element.links.forEach(function(element,index,fullArray){
	    // \href{http:///fooo.bar}{link text}
	    console.log('url:'+(element.link).replace(/\&/g,'\&')) //hrefP
	    console.log('description:'+(element.description).replace(/\&/g,'\&'))
	})
    }

})

console.log('\\end{document}')

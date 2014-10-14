var readline=require('readline')
var fs=require('fs')

console.log('{"journal":[')

var filename='/home/puffjay/Muddle.txt'
if (typeof process.argv[2] !== 'undefined') {
    filename=process.argv[2]
}
var rl = readline.createInterface({
    input : fs.createReadStream(filename),
    output: process.stdout,
    terminal: false
})

var buffer = ''//undefined
var linkBuffer = ''//undefined having them undefined actually puts the text 'undefined' in the output stream

//readline code

rl.on('line',function(line){
    var dateRE = /[MTWFS][ouehra][neduit] [JFMASOND][aepuco][nbrylgptvc] {1,2}[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2} [A-Z]{3} [0-9]{4}/ ///^Mon |^Tue.*|^Wed.* /  
    dateRE = /^[A-Z][a-z][a-z] [A-Z][a-z][a-z] {1,2}[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2} [A-Z]{3} [0-9]{4}$/
	
    var dateMatch = line.match(dateRE)

    //if we found a date, flush output content for the previous date
    if (dateMatch !== null) {
	if (typeof buffer !== 'undefined' 
	    && buffer !== '') {
	    console.log('"content":"'+buffer+'"')
	    //only output linkBuffer if there is content
	    if (typeof linkBuffer !== 'undefined' ){
		//slice off last comma
		console.log(',\n"links":['+linkBuffer.slice(0,-2)+"]")
	    }
	    console.log('},')
	    //reset buffers
	    linkBuffer = ''
	    buffer = ''
	}
	console.log('{"date":"'+(dateMatch[0]).trim()+'",')
    }
    //if the line doesn't contain a date, add content to buffer
    if (dateMatch===null) {
	var links = extractLinks(line)
	if ( links !== null ) { 
	    linkBuffer += links+",\n"
	}
	if ( line !== '' ) {
	    buffer+=line+'\\n'
	}
    }
})


rl.on('close',function() {
    //flush out the final lines of data

    if (typeof buffer !== 'undefined' 
	&& buffer !== '') {
	console.log('"content":"'+buffer+'"')
    }
    //only output linkBuffer if there is content
    if (typeof linkBuffer !== 'undefined' ){
	//slice off last comma
	console.log(',\n"links":['+linkBuffer.slice(0,-2)+"]")
    }
    //close out the json object
    console.log("} ] }") //close out the last object, the array of objects in the journal and finally the journal itself
})

//end readline code

function extractLinks(line) { 
    //http://stackoverflow.com/questions/10570286/check-if-string-contains-url-anywhere-in-string-using-javascript
    //http://stackoverflow.com/questions/5717093/check-if-a-javascript-string-is-an-url
//relevant about matching urls: http://stackoverflow.com/questions/37684/how-to-replace-plain-urls-with-links
//http://stackoverflow.com/questions/26348327/javascript-regex-match-text-after-pattern my question with answer to match the text after the pattern
    var urlRE= new RegExp("((?:[a-zA-Z0-9]+://)?(?:[a-zA-Z0-9_]+:[a-zA-Z0-9_]+@)?(?:[a-zA-Z0-9.-]+\\.[A-Za-z]{2,4})(?::[0-9]+)?(?:[^ ])+)(.*)$");
    var match = urlRE.exec(line);
    if ( match !== null ) {
	var url=match[1]
	var description=match[2]
//	console.log("---------:\\nmatch[0]:"+match[0] + "\\nmatch[1]:" + match[1] + "\\nmatch[2]:" + match[2]);
	if (typeof description !== 'undefined' 
	    && description !== '' ) {
	    return '{\n"link":"'+url+'",\n"description":"'+description.trim()+'"\n}'
	} else {
	    return '{\n"link":"'+url+'",\n"description":"'+url+'"\n}'
	}
    } else { 
	return null 
    }


}

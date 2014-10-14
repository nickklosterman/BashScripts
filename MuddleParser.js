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
	    console.log('"content":'+JSON.stringify(buffer))
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
	var links = extractLinks(line.replace(/"/g,'\"'))
	if ( links !== null ) { 
	    linkBuffer += links+",\n"
	}
	if ( line !== '' ) {
	    buffer+=line.replace(/"/g,'\"')+'\\n'
	}
    }
})


rl.on('close',function() {
    //flush out the final lines of data

    if (typeof buffer !== 'undefined' 
	&& buffer !== '') {
	console.log('"content":'+JSON.stringify(buffer))
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
//    var urlRE= new RegExp("((?:[a-zA-Z0-9]+://)?(?:[a-zA-Z0-9_]+:[a-zA-Z0-9_]+@)?(?:[a-zA-Z0-9.-]+\\.[A-Za-z]{2,4})(?::[0-9]+)?(?:[^ ])+)(.*)$");
// var urlRE = new RegExp('^(https?:\\/\\/)?'+ // protocol
//   '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ // domain name
//   '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
//   '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
//   '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
//   '(\\#[-a-z\\d_]*)?(.*)$','i');  // -----this one creates a group for each match. we don't want that!
// urlRE = new RegExp('^(https?:\\/\\/)?'+ // protocol
//   '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ // domain name
//   '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
//   '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
//   '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
//   '(\\#[-a-z\\d_]*)?(.*)$','g');  // -----this one creates a group for each match. we don't want that!

//slightly modified RE that matches http at the beg
//var  urlRE= new RegExp("(([http?]+:\/\/)?(?:[a-zA-Z0-9_]+:[a-zA-Z0-9_]+@)?(?:[a-zA-Z0-9.-]+\\.[A-Za-z]{2,4})(?::[0-9]+)?(?:[^ ])+)(.*)$"); //is matching traffic.libsyn somehow
//var  urlRE= new RegExp("^(((http?|ftp|file)+://)?(?:[a-zA-Z0-9_]+:[a-zA-Z0-9_]+@)?(?:[a-zA-Z0-9.-]+\\.[A-Za-z]{2,4})(?::[0-9]+)?(?:[^ ])+)(.*)$"); //line has to start w url so url can't be later in string :(
//    var urlRE= new RegExp("((?:[a-zA-Z0-9]{3,5}://)?(?:[a-zA-Z0-9_]+:[a-zA-Z0-9_]+@)?(?:[a-zA-Z0-9.-]+\\.[A-Za-z]{2,4})(?::[0-9]+)?(?:[^ ])+)(.*)$"); //tried to restrict protocol to 3-5 chars.....but for traffic.libysn there is no protocol! shit
var  urlRE= new RegExp("(((http?|ftp|file)+://)?(?:[a-zA-Z0-9_]+:[a-zA-Z0-9_]+@)?(?:[a-zA-Z0-9.-]+\\.[A-Za-z]{2,4})(?::[0-9]+)?(?:[^ ])+)(.*)$"); //line has to start w url so url can't be later in string :(
    var match = urlRE.exec(line);
    if ( match !== null ) {
//	console.log(match)
	var url=match[1] //match[1]+match[2]+match[3]+match[4]+match[5]+match[6]
	var description=match[3]//match[2]
//	console.log("---------:\\nmatch[0]:"+match[0] + "\\nmatch[1]:" + match[1] + "\\nmatch[2]:" + match[2]);
	if (typeof description !== 'undefined' 
	    && description !== '' ) {
	    return '{\n"link":"'+url+'",\n"description":'+JSON.stringify(description.trim())+'\n}'
	} else {
	    return '{\n"link":"'+url+'",\n"description":"'+url+'"\n}'
	}
    } else { 
	return null 
    }


}

//to validate the output json , install jsonlint
// npm install jsonlint -g 
// then run 
// jsonlint myfile.json

//instead of buffer.replace(/"/g,'\"') to escape double quotes, JSON.stringify seemed a much better solution
//http://stackoverflow.com/questions/2732409/how-can-i-put-double-quotes-inside-a-string-within-an-ajax-json-response-from-ph be careful though using JSON.parse & JSON.stringify

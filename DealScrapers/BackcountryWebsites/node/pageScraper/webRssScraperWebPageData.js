var request = require('request')
, cheerio = require('cheerio')
, fs = require('fs')
//, sqlite = require('sqlite3');
, mongoClient = require('mongodb').MongoClient;

var SACtimeremaining = 0.001
, WMtimeremaining = 0.001
, CLtimeremaining = 0.001;

var oldSAC = "",
oldWM = "",
oldCL = "";

var pageArray = [
    {url:"http://www.steepandcheap.com/current-steal",type:0,site:"SAC"},
    {url:"http://www.whiskeymilitia.com/",type:1,site:"WM"},
    {url:"http://www.chainlove.com/",type:1,site:"CL"}
];


var stripData=function(pageObj){
    //find index of our string for our json, find the index of the EOL starting from where we found our first search text. 
    var searchStringStart = "BCNTRY.page_data = ";
    
    if ( pageObj.type === 0){
	searchStringStart = "window.BC.currentSteal = ";
    }

    request(pageObj.url, function(err, resp, body) {
	if (err)
    	    throw err;

	var offset = searchStringStart.length;
	var currentStealStart = body.indexOf(searchStringStart);
	var currentStealEnd = body.indexOf("};",currentStealStart);
	var detailsJSON = body.substring(currentStealStart+offset,currentStealEnd+1);
	var parsedDetailsJSON = JSON.parse(detailsJSON);
	if (parsedDetailsJSON.hasOwnProperty('prev_items')){
	    delete parsedDetailsJSON['prev_items'];
	}

	switch (pageObj.site) {
	case "SAC":
	    SACtimeremaining = parseInt(parsedDetailsJSON.timeRemaining,10);
if (typeof SACtimeremaining === 'number') { 
console.log("Number"); 
}else {
console.log("not number");
}
	    console.log(parsedDetailsJSON.name+" SACtr:"+SACtimeremaining);
	    setInterval(stripData(pageArray[0]),SACtimeremaining*1000);

	    break;
	case "WM":
	    var searchString = "setupWMTimerBar(";
	    var start = body.indexOf(searchString);
	    var end = body.indexOf(",",start+1);
	    WMtimeremaining = parseInt(body.substring(start+searchString.length,end),10);
	    console.log(parsedDetailsJSON.productTitle+"WMtr:"+WMtimeremaining);
	    setInterval(stripData(pageArray[1]),WMtimeremaining*1000);


	    break;
	case "CL":
	    var searchString = "setupTimerBar(";
	    var start = body.indexOf("setupTimerBar(");
	    var end = body.indexOf(",",start+1);
	    CLtimeremaining = parseInt(body.substring(start+searchString.length,end),10);
	    console.log(parsedDetailsJSON.productTitle+"CLtr:"+CLtimeremaining);
	    setInterval(stripData(pageArray[2]),CLtimeremaining*1000);
	    break;
	default: 
	    SACtimeremaining=10;
	    WMtimeremaining=10;
	    CLtimeremaining=10;
	}
	parsedDetailsJSON.site=pageObj.site;

	//  console.log(detailsJSON);
	enterData(parsedDetailsJSON);
    })
};

    var enterData = function(data){
	//bc will be the name of the database
	mongoClient.connect('mongodb://127.0.0.1:27017/bc',function(err,db){
	    if (err) {throw err;}
	    //deals will be the name of the table/colleciton
	    var collection  = db.collection('deal');
	    if (data  !== undefined) {
		//console.log(data)
		collection.insert(data,function(err,data) {
		    if (err) { throw err;}
		    db.close();//node will hang without this 
		});
	    }

	});
    }

if ( 1===1){
    for (var counter = 0; counter < pageArray.length; counter++) {
    	var page = pageArray[counter];
    	stripData(page);
    }

// setInterval(stripData(pageArray[0]),SACtimeremaining*1000);
// setInterval(stripData(pageArray[1]),WMtimeremaining*1000);
// setInterval(stripData(pageArray[2]),CLtimeremaining*1000);


} else {

    mongoClient.connect('mongodb://127.0.0.1:27017/bc',function(err,db){
   	if (err) {throw err;}
	var collection  = db.collection('deal');
	collection.find().toArray(function(err,results) {
	    console.log('----=====----');
   	    console.log(results);
   	    db.close();
   	});
    });
}


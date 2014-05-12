var request = require('request')
, fs = require('fs')
, mongoClient = require('mongodb').MongoClient;

var SACtimeremaining = 0.001
, WMtimeremaining = 0.001
, CLtimeremaining = 0.001;

var previous = {SAC: "",
WM: "",
CL: ""};

var pageArray = [
    {url:"http://www.steepandcheap.com/current-steal",type:0,site:"SAC",previous:""},
    {url:"http://www.whiskeymilitia.com/",type:1,site:"WM",previous:""},
    {url:"http://www.chainlove.com/",type:1,site:"CL",previous:""}
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
// if (typeof SACtimeremaining === 'number') { 
// console.log("Number"); 
// }else {
// console.log("not number");
// }
	    console.log(parsedDetailsJSON.name+" SACtr:"+SACtimeremaining);
	    setTimeout(stripData,SACtimeremaining*1000,pageArray[0]);
	    if (pageObj.previous.odatId != parsedDetailsJSON.odatId) {
		pageObj.previous = parsedDetailsJSON;
console.log("Entering SAC data");
		enterData(parsedDetailsJSON);
	    }
	    break;
	case "WM":
	    var searchString = "setupWMTimerBar(";
	    var start = body.indexOf(searchString);
	    var end = body.indexOf(",",start+1);
	    WMtimeremaining = parseInt(body.substring(start+searchString.length,end),10);
	    console.log(parsedDetailsJSON.productTitle+"WMtr:"+WMtimeremaining);
	    setTimeout(stripData,WMtimeremaining*1000,pageArray[1]);

	    if (pageObj.previous.odat_id !== parsedDetailsJSON.odat_id) {
		pageObj.previous = parsedDetailsJSON;
		console.log("Entering WM data");
		enterData(parsedDetailsJSON);
	    }
	    break;
	case "CL":
	    var searchString = "setupTimerBar(";
	    var start = body.indexOf("setupTimerBar(");
	    var end = body.indexOf(",",start+1);
	    CLtimeremaining = parseInt(body.substring(start+searchString.length,end),10);
	    console.log(parsedDetailsJSON.productTitle+"CLtr:"+CLtimeremaining);
	    setTimeout(stripData,CLtimeremaining*1000,pageArray[2]);

	    if (pageObj.previous.odat_id != parsedDetailsJSON.odat_id) {
		pageObj.previous = parsedDetailsJSON;
		console.log("Entering CL data");
		enterData(parsedDetailsJSON);
	    }
	    break;
	default: 
	    SACtimeremaining=10;
	    WMtimeremaining=10;
	    CLtimeremaining=10;
	}
	parsedDetailsJSON.site=pageObj.site;

	//  console.log(detailsJSON);

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

// setTimeout(stripData(pageArray[0]),SACtimeremaining*1000);
// setTimeout(stripData(pageArray[1]),WMtimeremaining*1000);
// setTimeout(stripData(pageArray[2]),CLtimeremaining*1000);


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


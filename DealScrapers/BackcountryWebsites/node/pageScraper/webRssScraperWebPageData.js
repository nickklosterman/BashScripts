/*
This program scrapes the 3 Backcountry deals websites and enters the data into the local
mongo database. If multiple instances are running they will all write the data to the mongo db.
*/
var request = require('request')
, fs = require('fs')
, mongoClient = require('mongodb').MongoClient;

var shortWaitTime = 15;

//the countdown is done on the client so we have no control over that part :/

var db, collection;
mongoClient.connect('mongodb://127.0.0.1:27017/bc',function(err,database){
    if (err) {throw err;}
    db = database;
    //deals will be the name of the table/colleciton
    collection  = db.collection('deal');
    console.log('initialized database');
    Main();
});

var SACtimeremaining = 0.001
, WMtimeremaining = 0.001
, CLtimeremaining = 0.001;

var pageArray = [
    {url:"http://www.steepandcheap.com/current-steal",type:0,site:"SAC",previous:""},
    {url:"http://www.whiskeymilitia.com/",type:1,site:"WM",previous:""},
    {url:"http://www.chainlove.com/",type:1,site:"CL",previous:""}
];


var getLastEntry=function(Obj){
    collection.find({site:Obj.site}).sort({_id:-1}).limit(1).toArray(function(err,data) {
        if (err) { throw err;}
        else { 
	    if (typeof data !== 'undefined' && data.length > 0) {
                switch(Obj.site){
                case "WM":
		    console.log("WM:"+data[0].productTitle);
		    pageArray[1].previous=data[0];
		    break;
                case "CL":
		    console.log("CL:"+data[0].productTitle);
		    pageArray[2].previous=data[0];
		    break;
                case "SAC":
		    console.log("SAC:"+data[0]);
		    console.log("SAC:"+data[0].brand.name+' '+data[0].name);
		    pageArray[0].previous=data[0];
		    break;
		default:
		    console.log("no site match");
		    break;
                }
	    }
	}
//        db.close();//node will hang without this
    });
};


//checks the websites and sets the setTimeout with the time remaining as parsed from the file. 
var stripData=function(pageObj){
    //find index of our string for our json, find the index of the EOL starting from where we found our first search text. 
    var searchStringStart = "BCNTRY.page_data = ";
    
    if ( pageObj.type === 0){
	searchStringStart = "window.BC.currentSteal = ";
    }

    request(pageObj.url, function(err, resp, body) {
	if (err)
    	    throw err; //I need to more gracefully handle errors especially if the webpage isn't accessible, they are blocking our scraping or some other reason. 

	var offset = searchStringStart.length;
	var currentStealStart = body.indexOf(searchStringStart);
	var currentStealEnd = body.indexOf("};",currentStealStart);
	var detailsJSON = body.substring(currentStealStart+offset,currentStealEnd+1);
	var parsedDetailsJSON = JSON.parse(detailsJSON);
	if (typeof parsedDetailsJSON !== 'undefined' && parsedDetailsJSON.hasOwnProperty('prev_items')){
	    delete parsedDetailsJSON['prev_items'];
	}

	switch (pageObj.site) {
	case "SAC":
	    SACtimeremaining = parseInt(parsedDetailsJSON.timeRemaining,10);
	    if (pageObj.previous.odatId != parsedDetailsJSON.odatId) {
		console.log("Entering SAC data:"+pageObj.previous.odatId+' -> '+parsedDetailsJSON.odatId);
		pageObj.previous = parsedDetailsJSON;
		enterData(parsedDetailsJSON);
	    } else { // the product hasn't changed
		//ignore whatever the time remaining we parsed from the webpage and set to a small value
		//I haven't seen a case where a product appears twice with the timer 'refreshed'
		//I *have* seen a case where the product stays and the timer is 'refreshed' to then be replaced seconds later.
		//this logic is to prevent such a case where we wait another 10minutes before checking again even though a new product just appeared seconds after our last check.
		SACtimeremaining = shortWaitTime;
	    }
	    console.log(parsedDetailsJSON.name+" SACtr:"+SACtimeremaining);
	    setTimeout(stripData,SACtimeremaining*1000,pageArray[0]);
	    break;
	case "WM":
	    var searchString = "setupWMTimerBar(";
	    var start = body.indexOf(searchString);
	    var end = body.indexOf(",",start+1);
	    WMtimeremaining = parseInt(body.substring(start+searchString.length,end),10);
	    start = end;
	    end = body.indexOf(')',start+1);
	    WMduration = parseInt(body.substring(start+1,end),10);
	    parsedDetailsJSON.duration=WMduration;
	    if (pageObj.previous.odat_id !== parsedDetailsJSON.odat_id) {
		pageObj.previous = parsedDetailsJSON;
		console.log("Entering WM data:"+pageObj.previous.odat_id+' -> '+parsedDetailsJSON.odat_id);
		pageObj.previous = parsedDetailsJSON;
		enterData(parsedDetailsJSON);
	    } else { 
		WMtimeremaining = shortWaitTime;
	    }
	    console.log(parsedDetailsJSON.productTitle+"WMtr:"+WMtimeremaining+' /'+WMduration);
	    setTimeout(stripData,WMtimeremaining*1000,pageArray[1]);
	    break;
	case "CL":
	    var searchString = "setupTimerBar(";
	    var start = body.indexOf("setupTimerBar(");
	    var end = body.indexOf(",",start+1);
	    CLtimeremaining = parseInt(body.substring(start+searchString.length,end),10);
	    start = end;
	    end = body.indexOf(')',start+1);
	    CLduration = parseInt(body.substring(start+1,end),10);
	    parsedDetailsJSON.duration=CLduration;
	    if (pageObj.previous.odat_id != parsedDetailsJSON.odat_id) {
		console.log("Entering CL data:"+pageObj.previous.odat_id+' -> '+parsedDetailsJSON.odat_id);
		pageObj.previous = parsedDetailsJSON;
		enterData(parsedDetailsJSON);
	    } else {
		CLtimeremaining = shortWaitTime;
	    }
	    console.log(parsedDetailsJSON.productTitle+"CLtr:"+CLtimeremaining+' /'+CLduration);
	    setTimeout(stripData,CLtimeremaining*1000,pageArray[2]);
	    break;
	default: 
	    SACtimeremaining=10;
	    WMtimeremaining=10;
	    CLtimeremaining=10;
	}
	parsedDetailsJSON.site=pageObj.site;
    })
};


//Checks the websites for updates every timeoutInterval seconds. 
function stripDataCyclic(pageObj){
var timeoutInterval = 45;  //number of seconds to wait before checking for changes.
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
	if (typeof parsedDetailsJSON !== 'undefined' && parsedDetailsJSON.hasOwnProperty('prev_items')){
	    delete parsedDetailsJSON['prev_items'];
	}

	switch (pageObj.site) {
	case "SAC":
	    SACtimeremaining = parseInt(parsedDetailsJSON.timeRemaining,10);
	    if (pageObj.previous.odatId != parsedDetailsJSON.odatId) {
		console.log("Entering SAC data:"+pageObj.previous.odatId+' -> '+parsedDetailsJSON.odatId);
		pageObj.previous = parsedDetailsJSON;
		enterData(parsedDetailsJSON);
	    } else { // the product hasn't changed
		//ignore whatever the time remaining we parsed from the webpage and set to a small value
		//I haven't seen a case where a product appears twice with the timer 'refreshed'
		//I *have* seen a case where the product stays and the timer is 'refreshed' to then be replaced seconds later.
		//this logic is to prevent such a case where we wait another 10minutes before checking again even though a new product just appeared seconds after our last check.
	    }
	    console.log(parsedDetailsJSON.name+" SACtr:"+SACtimeremaining);
	    setTimeout(stripDataCyclic,timeoutInterval*1000,pageArray[0]);
	    break;
	case "WM":
	    var searchString = "setupWMTimerBar(";
	    var start = body.indexOf(searchString);
	    var end = body.indexOf(",",start+1);
	    WMtimeremaining = parseInt(body.substring(start+searchString.length,end),10);
	    start = end;
	    end = body.indexOf(')',start+1);
	    WMduration = parseInt(body.substring(start+1,end),10);
	    parsedDetailsJSON.duration=WMduration;
	    if (pageObj.previous.odat_id !== parsedDetailsJSON.odat_id) {
		pageObj.previous = parsedDetailsJSON;
		console.log("Entering WM data:"+pageObj.previous.odat_id+' -> '+parsedDetailsJSON.odat_id);
		pageObj.previous = parsedDetailsJSON;
		enterData(parsedDetailsJSON);
	    } else { 

	    }
	    console.log(parsedDetailsJSON.productTitle+"WMtr:"+WMtimeremaining+' /'+WMduration);
	    setTimeout(stripDataCyclic,timeoutInterval*1000,pageArray[1]);
	    break;
	case "CL":
	    var searchString = "setupTimerBar(";
	    var start = body.indexOf("setupTimerBar(");
	    var end = body.indexOf(",",start+1);
	    CLtimeremaining = parseInt(body.substring(start+searchString.length,end),10);
	    start = end;
	    end = body.indexOf(')',start+1);
	    CLduration = parseInt(body.substring(start+1,end),10);
	    parsedDetailsJSON.duration=CLduration;
	    if (pageObj.previous.odat_id != parsedDetailsJSON.odat_id) {
		console.log("Entering CL data:"+pageObj.previous.odat_id+' -> '+parsedDetailsJSON.odat_id);
		pageObj.previous = parsedDetailsJSON;
		enterData(parsedDetailsJSON);
	    } else {

	    }
	    console.log(parsedDetailsJSON.productTitle+"CLtr:"+CLtimeremaining+' /'+CLduration);
	    setTimeout(stripDataCyclic,timeoutInterval*1000,pageArray[2]);
	    break;
	default: 
	    SACtimeremaining=10;
	    WMtimeremaining=10;
	    CLtimeremaining=10;
	}
	parsedDetailsJSON.site=pageObj.site;
    })
};

//Write the date and site to a file. Another node app watches this file and 
//triggers a socket event when it is updated getting the latest data from mongo
var flagFile = function(site) {
    var time = new Date().toJSON();
    fs.writeFile('/tmp/BackCountryHeartbeat.txt', site+','+time, function(err) {
        if(err) {
            console.log(err);
        } else {
            console.log("The file was saved!");
        }
    });
};

var enterData = function(data){
    //bc will be the name of the database
    if (data  !== undefined) {
	collection.insert(data,function(err,doc) {
	    if (err) { throw err;}
	    console.log('data.site:'+data.site);
	    flagFile(data.site);//
//	    db.close();//node will hang without this 
	});
    }
}



function Main() {
    //get the most recent entries from the database
    for (var cntr = 0; cntr < pageArray.length; cntr++) {
	getLastEntry(pageArray[cntr]);
    }

    //Delay the start so that data for the last entries can be extracted from the database.
    var delayed = function() {
	for (var counter = 0; counter < pageArray.length; counter++) {
    	    var page = pageArray[counter];
    	    stripData(page);
	    //stripDataCyclic(page);
	}
    }
    setTimeout(delayed,500);
};


    // Main() is called from the callback for mongoClient initing, otherwise the mongo variables aren't initialized yet.
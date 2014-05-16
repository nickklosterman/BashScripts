var express = require('express')
, mongoClient = require('mongodb').MongoClient;

var app = express();
function getRecordsFromDB(site,callback) {
    var output;
    mongoClient.connect('mongodb://127.0.0.1:27017/bc',function(err,db){
	if (err) {throw err;}
	//deals will be the name of the table/colleciton
	var collection  = db.collection('deal');
	output="<ul>";
	var image;
//console.log(site);
	collection.find({site:site}).sort({_id:-1}).limit(14).toArray(function(err,data) {
	    if (err) { throw err;}
	    else {
		switch(site){
		case "WM":
		case "CL":
		    for (var counter = 0, size=data.length; counter<size;counter++){
			//for these, the quantity is in the 'variant' data; I think it might also be elsewhere in the html of the page in the javascript
			if (data[counter].variants) { 
			    for (var key in data[counter].variants) { /*console.log(key);*/ break;}
//			    console.log(key);
			    if (data[counter].variants[key].images && data[counter].variants[key].images.mediumImage !== null){
				image =  data[counter].variants[key].images.mediumImage;
			    } else if (data[counter].variants[key].images && data[counter].variants[key].images.smallImage !== null){
				image = data[counter].variants[key].images.smallImage;
			    } else { image = ":(";}
			}
//			console.log(data[counter].productTitle+' $'+data[counter].price);
			var link="";
			if (counter===0 ) {
			    switch (site){
			    case "WM":
				link="http://www.whiskeymilitia.com";
				break;

			    case "CL":
				link="http://www.chainlove.com";
				break;
			    }
			    output+='<li> <a href="'+link+'"><img  src="'+image+'"> </a>'+data[counter].productTitle+' $'+data[counter].price+'</li>';
			} else {
			output+='<li> <img src="'+image+'">'+data[counter].productTitle+' $'+data[counter].price+'</li>';
			}
		    }
		    break;
		case "SAC":
		    for (var counter = 0, size=data.length; counter<size;counter++){
//			console.log(data[counter].brand.name+data[counter].name+' $'+data[counter].price);
			
			if (data[counter].defaultImage && data[counter].defaultImage.url.medium) {
			    image = data[counter].defaultImage.url.medium;
			} else if (data[counter].defaultImage && data[counter].defaultImage.url.tiny) {
			    image = data[counter].defaultImage.url.url.tiny;
			}
			if (counter===0) {
			    output+='<li> <a href="http://www.steepandcheap.com/current-steal"> <img height="100" width="100" src="'+image+'"> </a>'+data[counter].brand.name+' '+data[counter].name+' $'+data[counter].price+' duration:'+data[counter].duration+' quantity:'+data[counter].qtyInitial+'</li>';
			} else {
			    output+='<li> <img height="100" width="100" src="'+image+'">'+data[counter].brand.name+' '+data[counter].name+' $'+data[counter].price+' duration:'+data[counter].duration+' quantity:'+data[counter].qtyInitial+'</li>';
			}

		    }
		    break;
		}
	    }
	    db.close();//node will hang without this 
	output+="</ul>";
//	console.log(output);
	console.log("finish up getRecordsFromDB");
	callback( output);

	});

    });

};

app.get('/data/',function(req, res) {
    var output="<meta http-equiv='refresh' content='60'>"
    getRecordsFromDB("SAC",function(o){output+=o+"<hr>"; sendResponse(); console.log("1");});
    getRecordsFromDB("CL", function(o){output+=o+"<hr>"; sendResponse(); console.log("2");});
    getRecordsFromDB("WM", function(o){output+=o;        sendResponse(); console.log("3");});
    var counter=0;
    function sendResponse(){
	console.log("send resp: ctr:"+counter);
	counter+=1;
	if (counter===3) {  
	    res.send(output); // I need this to wait until the output is all returned 
	}
    }

  //  console.log("finish up app.get /data/ route");
//next();
});

app.get('/data/:site?', function( req, res, next) {
    var site = req.params.site;
    //res.send('you want data from '+site);
    var output="";
    mongoClient.connect('mongodb://127.0.0.1:27017/bc',function(err,db){
	if (err) {throw err;}
	//deals will be the name of the table/colleciton
	var collection  = db.collection('deal');
	var output="<meta http-equiv='refresh' content='60'> <ul>";
	var image;
	collection.find({site:site}).sort({_id:-1}).limit(14).toArray(function(err,data) {
	    if (err) { throw err;}
	    else {
		switch(site){
		case "WM":
		case "CL":
		    for (var counter = 0, size=data.length; counter<size;counter++){
			//for these, the quantity is in the 'variant' data; I think it might also be elsewhere in the html of the page in the javascript
			if (data[counter].variants) { 
			    for (var key in data[counter].variants) {console.log(key); break;}
			    console.log(key);
			    if (data[counter].variants[key].images && data[counter].variants[key].images.mediumImage !== null){
				image =  data[counter].variants[key].images.mediumImage;
			    } else if (data[counter].variants[key].images && data[counter].variants[key].images.smallImage !== null){
				image = data[counter].variants[key].images.smallImage;
			    } else { image = ":(";}
			}
			console.log(data[counter].productTitle+' $'+data[counter].price);
			output+='<li> <img src="'+image+'">'+data[counter].productTitle+' $'+data[counter].price+'</li>';
		    }
		    console.log(data);
		    break;
		case "SAC":
		    for (var counter = 0, size=data.length; counter<size;counter++){
			console.log(data[counter].brand.name+data[counter].name+' $'+data[counter].price);
			if (data[counter].defaultImage && data[counter].defaultImage.url.medium) {
			    image = data[counter].defaultImage.url.medium;
			} else if (data[counter].defaultImage && data[counter].defaultImage.url.tiny) {
			    image = data[counter].defaultImage.url.url.tiny;
			}
			output+='<li> <img height="100" width="100" src="'+image+'">'+data[counter].brand.name+' '+data[counter].name+' $'+data[counter].price+' duration:'+data[counter].duration+' quantity:'+data[counter].qtyInitial+'</li>';

		    }
		    console.log(data);
		    break;
		}
	    }
	    db.close();//node will hang without this 
	    res.send(output);
	});
    });
//    next(); //if I by default just hit next, since I already wrote via res.send, the next res.send will give me the "Error: Can't set headers after they are sent." error
//next(); //otherwise it won't fall through to next route
});

app.get('/data/*?',function(req, res) {
    console.log('foo');
    res.send('no data source given');

});


app.get('/?', function( req, res, next) {
    res.send('hello world');
});

var port = 8080;
app.listen(port);
console.log('listening on port '+port);

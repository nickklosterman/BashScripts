var express = require('express')
, mongoClient = require('mongodb').MongoClient;

var app = express();

app.get('/data/:site?', function( req, res, next) {
    var site = req.params.site;
//  res.send('you want data from '+site);
    var output="";
    mongoClient.connect('mongodb://127.0.0.1:27017/bc',function(err,db){
	if (err) {throw err;}
	//deals will be the name of the table/colleciton
	var collection  = db.collection('deal');
	var output="<ul>";
	collection.find({site:site}).limit(21).toArray(function(err,data) {
	    if (err) { throw err;}
	    else {
		switch(site){
		case "WM":
		case "CL":
		    for (var counter = 0, size=data.length; counter<size;counter++){
			console.log(data[counter].productTitle+' $'+data[counter].price);
			output+='<li>'+data[counter].productTitle+' $'+data[counter].price+'</li>';
		    }
		    console.log(data);
		    break;
		case "SAC":
		    for (var counter = 0, size=data.length; counter<size;counter++){
			console.log(data[counter].brand.name+data[counter].name+' $'+data[counter].price);
			output+='<li>'+data[counter].brand.name+' '+data[counter].name+' $'+data[counter].price+' duration:'+data[counter].duration+' quantity:'+data[counter].qtyInitial+'</li>';

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

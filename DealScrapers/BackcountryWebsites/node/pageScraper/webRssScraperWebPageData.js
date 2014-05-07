var request = require('request')
, cheerio = require('cheerio')
, fs = require('fs')
, sqlite = require('sqlite3');

pageArray = [
{url:"http://www.steepandcheap.com/current-steal",type:0},
{url:"http://www.whiskeymilitia.com/",type:1},
{url:"http://www.chainlove.com/",type:1}
];



for (var counter = 0; counter < pageArray.length; counter++) {
    var page = pageArray[counter];

//find index of our string for our json, find the index of the EOL starting from where we found our first search text. 
var searchStringStart = "BCNTRY.page_data = ";

    if ( page.type === 0){
	searchStringStart = "window.BC.currentSteal = ";
    }

  var myfunc=function(url,searchStringStart){
	request(url, function(err, resp, body) {
	    if (err)
    		throw err;
	    var offset = searchStringStart.length;
	    var currentStealStart = body.indexOf(searchStringStart);
	    //var productStart = body.indexOf("window.BC.product =");
	    var currentStealEnd = body.indexOf("};",currentStealStart);
	    //var productEnd = body.indexOf("};",productStart);
	    var detailsJSON = body.substring(currentStealStart+offset,currentStealEnd+1);
	    var parsedDetailsJSON = JSON.parse(detailsJSON);
	    if (parsedDetailsJSON.hasOwnProperty('prev_items')){
		delete parsedDetailsJSON['prev_items'];
	    }
		//  console.log(detailsJSON);
	    console.log('----------------------');
	    console.log(parsedDetailsJSON);
	    console.log('----------------------');
	})
  }(page.url,searchStringStart);
    

}
    
    //var db = new sqlite3.Database(sqliteDatabaseName);
/*
will need a timestampe for the json entry or something to sort or query on
   var db = new sqlite3.Database(sqlite_database);
  if (req.params.date) {
    db.all(
      util.format('SELECT rank,stockticker from BC20 where Date="%s" order by Rank Asc', req.params.date),
      function(err, rows) {
        db.close();
        if (err) return res.json(501, { error: err.message });
        res.json(rows);
      });
  } else {
    db.all('SELECT distinct(date) from BC20', function(err, rows) {
      db.close();
      if (err) return res.json(501, { error: err.message });
      res.json(rows);
    });
  }
};
stackoverflow.com/.../read-nth-line-of-file-in-nodejs‎....well shit I don't want to READ the file since I have it in memory as the body
*/



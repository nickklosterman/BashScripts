var request = require('request')
, cheerio = require('cheerio')
, fs = require('fs')
, sqlite = require('sqlite3');


urlArray = [
"http://rss.chainlove.com/docs/chainlove/rss.xml"
,"http://rss.whiskeymilitia.com/docs/wm/rss.xml"
,"http://rss.steepandcheap.com/docs/steepcheap/rss.xml"
];

pageArray = [
"http://www.steepandcheap.com/current-steal",
"http://www.whiskeymilitia.com/",
"http://www.chainlove.com/"
];

for (var counter = 0; counter < urlArray.length; counter++) {
    var url=urlArray[counter];
    var myfunc=function(url){
	request(url, function(err, resp, body) {
	    if (err)
    		throw err;
	    var myurl=url.split('.')[1];
	    //cheerio can't handle fake element tags like odat:price so we translate them to remove the :
	    $ = cheerio.load(body.replace(/odat:price/g,"odatPrice").replace(/sac:price/g,"odatPrice"));//,{xmlMode:true});
//	    var titleArray=$('title'); //https://www.npmjs.org/package/cheerio 
	    var title=$('title').slice(1).eq(0).text(); //this is the second title
//	    var priceArray=$('odatPrice'); //https:www.npmjs.org/package/cheerio 
	    var price=$('odatPrice').slice(0).eq(0).text(); //this is the first odatPrice element
	    priceArray=$('odatPrice');//https:www.npmjs.org/package/cheerio 
	    console.log(myurl+":"+title+"---"+price);
	})
    }(url);
}
for (var counter = 0; counter < pageArray.length; counter++) {
    var page = pageArray[counter];
//find index of our string for our json, find the index of the EOL starting from where we found our first search text. 
}
    
    //var db = new sqlite3.Database(sqliteDatabaseName);
/*
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



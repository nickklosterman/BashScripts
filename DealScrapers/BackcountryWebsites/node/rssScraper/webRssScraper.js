var request = require('request')
, cheerio = require('cheerio')
, fs = require('fs');
//, sqlite = require('sqlite3');


urlArray = [
"http://rss.chainlove.com/docs/chainlove/rss.xml"
,"http://rss.whiskeymilitia.com/docs/wm/rss.xml"
,"http://rss.steepandcheap.com/docs/steepcheap/rss.xml"
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




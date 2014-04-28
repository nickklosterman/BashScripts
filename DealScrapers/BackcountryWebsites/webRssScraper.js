var request = require('request');
var cheerio = require('cheerio');
var fs = require('fs');

urlArray = [
"http://rss.chainlove.com/docs/chainlove/rss.xml"
,"http://rss.whiskeymilitia.com/docs/wm/rss.xml"
,"http://rss.steepandcheap.com/docs/steepcheap/rss.xml"
];


for (var counter = 0; counter < urlArray.length; counter++) {
    var imagecounter=0;
    var url=urlArray[counter];
    var myfunc=function(url){
	request(url, function(err, resp, body) {
	    if (err)
    		throw err;
	    var myurl=url.split('.')[1];
	    //cheerio can't handle fake element tags like odat:price so we translate them to remove the :
	    $ = cheerio.load(body.replace(/odat:price/g,"odatPrice").replace(/sac:price/g,"odatPrice"));
	    var titleArray=$('title').slice(1).eq(0).text(); //https://www.npmjs.org/package/cheerio 
	    var priceArray=$('odatPrice').slice(1).eq(0).text(); //https:www.npmjs.org/package/cheerio 
	    console.log(myurl+":"+titleArray+"---"+priceArray)
	})
    }(url);
}

    
    


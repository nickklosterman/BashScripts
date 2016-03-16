var request = require('request')
, cheerio = require('cheerio');

urlArray = [
    "http://www.steepandcheap.com/rss.xml",
    "http://www.whiskeymilitia.com/docs/wm/rss.xml"
];

for (var counter = 0; counter < urlArray.length; counter++) {
    var url=urlArray[counter];
    var myfunc=function(url){
	var options = {
	    url: url,
	    headers: {
		'User-Agent': 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36'
	    }
	};
	request(options, function(err, resp, body) {
	    if (err)
    		throw err;
	    var myurl=url.split('.')[1];
	    //cheerio can't handle fake element tags like odat:price so we translate them to remove the :
	    $ = cheerio.load(body.replace(/odat:priceCurrent/g,"odatPrice").replace(/sac:priceCurrent/g,"odatPrice"));
	    var title=$('item > title').slice(1).eq(0).text(); //this is the second title, the first title is '<title>Steepandcheap.com RSS</title>

	    var price=$('odatPrice').slice(0).eq(0).text(); //this is the first odatPrice element
	    priceArray=$('odatPrice');//https:www.npmjs.org/package/cheerio 
	    console.log(myurl+":"+title+" -=- $"+price);
	})
    }(url);
}




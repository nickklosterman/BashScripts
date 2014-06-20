var request = require('request');
var cheerio = require('cheerio');
var fs = require('fs');

var url="http://feeds.feedburner.com/BookDL?format=xml";
var myfunc=function(url){
    request(url, function(err, resp, body) {
	if (err)
    	    throw err;
	$ = cheerio.load(body.replace(/<!\[CDATA\[([^\]]+)]\]>/ig,''), {xmlMode:true});
	var priceArray=$('title').slice(1).eq(0).text(); //https:www.npmjs.org/package/cheerio 
	$('title').each(function(i, xmlItem){
	    if ( i > 1 && i < 10 ) //the 0th element is just the page title
		console.log($(this).text());
	});
    })
}(url);


    
    


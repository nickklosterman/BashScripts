var request = require('request');
var cheerio = require('cheerio');

urlArray = [
    "http://cucumber.gigidigi.com/cq/page-1/"
    ,"http://shiverbureau.com/2012/04/04/welcome-to-london-chapter-1-page-1/"
];

var getNextLink= function(body) {
    var nextLinkElement=$('link[rel=\'next\']');
    var nextLink=nextLinkElement[0].attribs.href;
    console.log(nextLinkElement[0].attribs.href);
};

var getComicImage=function(body){
    var comicImageElement=$('#comic-1 img'); //shiverbureau

    if (typeof comicImageElement[0] === 'undefined' || !comicImageElement[0].hasOwnProperty('attribs'))
    {
	comicImageElement=$('#webcomic img')
	//	    console.log(comicImageElement);
    } else {
	console.log("11nnnn11");
	//	    console.log(typeof comicImageElement[0].attribs );
    }
    
    //	console.log(comicImageElement['0']);//[0].attribs.src);
    //	console.log(comicImageElement);
    //	console.log(comicImageElement[0].attribs.src);
    //	console.log(comicImageElement[0].attribs.src);
    var comicImage=comicImageElement[0].attribs.src;
    console.log(comicImage);

};

for (var counter = 0; counter < urlArray.length; counter++) {
    var url=urlArray[counter];
    console.log('----');
    console.log(url);
    console.log('----');
    request(url, function(err, resp, body) {
            if (err)
    		throw err;
            $ = cheerio.load(body); //hmm so $ is global??
	getNextLink();
	getComicImage();
    });
   
}

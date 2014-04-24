var request = require('request');
var cheerio = require('cheerio');
var fs = require('fs');

// rar libs : https://www.npmjs.org/package/rarfile https://www.npmjs.org/package/rarjs

urlArray = [
//    "http://cucumber.gigidigi.com/cq/page-1/"    ,
//"http://shiverbureau.com/2012/04/04/welcome-to-london-chapter-1-page-1/" //the rel links sometimes take you to diff pages (blog pages) instead of the webcomic pages
"http://shiverbureau.com/2014/04/17/welcome-to-london-chapter-3-page-6"
];

var getNextLink= function(body) {
    console.log("current page:"+nextlink);
    var nextLinkElement=$('link[rel=\'next\']');
    if (typeof nextLinkElement !== 'undefined' && typeof nextLinkElement[0] !== 'undefined' && nextLinkElement[0].hasOwnProperty('attribs'))
    {
	var nextLink=nextLinkElement[0].attribs.href;
    }
    else {
	console.log("No next link found");
    }
    console.log("next link from currentpage:"+nextLink);
    return nextLink;
};

var searchForArchiveList = function() { 
//this should work for ShiverBureau
var archiveElement=$('select');
};

var getComicImage=function(counter){
    var comicImageElement=$('#comic-1 img'); //shiverbureau
    var comicImage;
    if (typeof comicImageElement[0] === 'undefined' || !comicImageElement[0].hasOwnProperty('attribs'))
    {
	comicImageElement=$('#webcomic img')
	//	    console.log(comicImageElement);
	if (typeof comicImageElement[0] !== 'undefined' && comicImageElement[0].hasOwnProperty('attribs')) 
	{
	    comicImage=comicImageElement[0].attribs.src;
	} else
	{ 
	    console.log("no image found");
	    console.log(comicImageElement);
	}
    } else {
	console.log("11nnnn11");
	//	    console.log(typeof comicImageElement[0].attribs );
	comicImage=comicImageElement[0].attribs.src;
    }

    console.log(comicImage);
//    var filename = sprintf("test%03d.png",) ; //shit didn't realize there is js implementation of sprintf but I don't wanna dl. http://www.diveintojavascript.com/projects/javascript-sprintf :(
    var fileprefix="test";
    var filenumber=pad(counter,4);
    var filesuffix="png";
    var filename=fileprefix+filenumber+"."+filesuffix;
    if (typeof comicImage !== 'undefined') {
    request(comicImage).pipe(fs.createWriteStream(filename)) //from  https://www.npmjs.org/package/request
}
};

var pad=function(num, size) { //http://stackoverflow.com/questions/2998784/how-to-output-integers-with-leading-zeros-in-javascript 
    var s = "0000" + num;
    return s.substr(s.length-size);
}

for (var counter = 0; counter < urlArray.length; counter++) {
    var imagecounter=0;
    var url=urlArray[counter];
    var nextlink=url;
    console.log('----');
    console.log(url);
    console.log('----');
    console.log(nextlink);
    imagecounter+=1;

    !function processUrl (url,counter){
	if (typeof url !=='undefined') {
	request(url, function(err, resp, body) {
	    if (err)
    		throw err;
	    $ = cheerio.load(body); //hmm so $ is global??
//	    console.log(counter);
	    
	    nextlink=getNextLink();
//	    console.log(nextlink)
	    getComicImage(counter);
	    processUrl(nextlink,counter+1);
	})
	}
    }(nextlink,imagecounter);

}

    
    


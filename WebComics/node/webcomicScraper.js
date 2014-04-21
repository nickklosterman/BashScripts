var request = require('request');
var cheerio = require('cheerio');
var fs = require('fs');

urlArray = [
    "http://cucumber.gigidigi.com/cq/page-1/"
    ,"http://shiverbureau.com/2012/04/04/welcome-to-london-chapter-1-page-1/"
];

var getNextLink= function(body) {
    var nextLinkElement=$('link[rel=\'next\']');
    var nextLink=nextLinkElement[0].attribs.href;
    console.log(nextLinkElement[0].attribs.href);
    nextlink = nextLinkElement[0].attribs.href;
    return nextLinkElement[0].attribs.href;
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
//    var filename = sprintf("test%03d.png",) ; //shit didn't realize there is js implementation of sprintf but I don't wanna dl. http://www.diveintojavascript.com/projects/javascript-sprintf :(
    var fileprefix="test";
    var filenumber=pad(imagecounter,4);
    var filesuffix="png";
    var filename=fileprefix+filenumber+"."+filesuffix;
    request(comicImage).pipe(fs.createWriteStream(filename)) //from  https://www.npmjs.org/package/request
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
    // request(url, function(err, resp, body) {
    //         if (err)
    // 		throw err;
    //         $ = cheerio.load(body); //hmm so $ is global??
    // 	nextlink=getNextLink();
    // 	getComicImage();
    // });

//this is a variable scoping problem with nextlink not changing.
    while (typeof nextlink !=='undefined' && imagecounter<10)
    {
	console.log(nextlink);
	request(nextlink, function(err, resp, body) {
            if (err)
    		throw err;
            $ = cheerio.load(body); //hmm so $ is global??
	    console.log(imagecounter);
	    imagecounter+=1;
	    nextlink=getNextLink();
	    console.log(nextlink)
	    getComicImage();
	});	
    }
    
    
}

var request = require('request'),
cheerio = require('cheerio'),
fs = require('fs'),
glob = require('glob');

// to test css selectors in firebug: in console type: $$('css selector') this will return an array
// in chrome use $('') or $$('') in the console

urlArray = [
//    "http://cucumber.gigidigi.com/cq/page-1/"    ,
//"http://shiverbureau.com/2012/04/04/welcome-to-london-chapter-1-page-1/" //the rel links sometimes take you to diff pages (blog pages) instead of the webcomic pages
//"http://shiverbureau.com/2014/04/17/welcome-to-london-chapter-3-page-6"
"http://gingerhaze.com/nimona/comic/page-1"
];

/*
starturl: url the webcomic starts on
title: used for the temporary files and the archive
fileextension: used for temporary files
baseurl: in the case where the next link is relative, used to create a full url
engine: optional to see what type of engine the author is using.
*/
webcomicArray = [
{
//http://cucumber.gigidigi.com/cq/page-498/ http://cucumber.gigidigi.com/cq/page-1/
starturl:"http://cucumber.gigidigi.com/cq/page-497/", title:"CucumberQuest",fileextension:"jpg",baseurl:"",engine:""}
//,{starturl:"http://gingerhaze.com/nimona/comic/page-1", title:"Nimona",fileextension:"jpg",baseurl:"http://gingerhaze.com",engine:"Drupal 7"}
];

/*
*
*
*Each one of the cases must work gracefully for all other webcomics. so it doesn't prevent a undefined from being set as the nextlink when the last page is handled. 
*/
var getNextLink= function(body) {
  //  console.log("current page:"+nextlink);
    var nextLinkElement=$('link[rel=\'next\']'); //<link rel='next' ...>
    if (typeof nextLinkElement !== 'undefined' && typeof nextLinkElement[0] !== 'undefined' && nextLinkElement[0].hasOwnProperty('attribs'))
    {
	var nextLink=nextLinkElement[0].attribs.href;
    }
    else {
	if( typeof nextLink === 'undefined'){
	    //	    nextLinkElement=$('a > img[src="http://gingerhaze.com/sites/default/files/comicdrop/comicdrop_next_label_file.png"]'); This won't work because this gets the child element of the one i want, and there is currently, as of early 2014, no way to get at the parent element via selectors

	    nextLinkElement=$('li > a'); //nimona
	    //I am blatantly banking on the format not changing such that the 8th element is the <a href...> that wraps the next button
	    if (typeof nextLinkElement !== 'typeof' 
		&& typeof nextLinkElement[8] !== 'undefined' 
		&& nextLinkElement[8].hasOwnProperty('attribs')) {

	    console.log(nextLinkElement[8]);
	    if (typeof nextLinkElement[8].attribs.hasOwnProperty('href')){
  		nextLink=baseurl+nextLinkElement[8].attribs.href;
	    }
}	    //	    console.log("nextLinkElement nimona:"+nextLinkElement);			      
	}	    else {
	    console.log("No next link found");
	}
    }
    console.log("next link from currentpage:"+nextLink);
    return nextLink;
};

var searchForArchiveList = function() { 
//this should work for ShiverBureau
var archiveElement=$('select');
};

var getComicImage=function(counter){
// switch (title){
// case "Nimona":
//     var comicImageElement=$('img #comic-1 img'); 
// break;
// }
    var comicImageElement=$('#comic-1 img'); //shiverbureau
    var comicImage;
    if (typeof comicImageElement[0] === 'undefined' || !comicImageElement[0].hasOwnProperty('attribs'))
    {
	comicImageElement=$('#webcomic img') //cucumberquest
	//	    console.log(comicImageElement);
	if (typeof comicImageElement[0] !== 'undefined' && comicImageElement[0].hasOwnProperty('attribs')) 
	{
	    comicImage=comicImageElement[0].attribs.src;
	} else 
	{ 
	    comicImageElement=$('img[typeof="foaf:Image"]');//nimona <img typeof="foaf:Image"
	    if (typeof comicImageElement[0] !== 'undefined' && comicImageElement[0].hasOwnProperty('attribs')) 
	    {
		comicImage=comicImageElement[0].attribs.src;
	    } else 
	    { 
		console.log("no image found"+comicImageElement);
	    }
	}
    } else {
	console.log("11nnnn11");
	//	    console.log(typeof comicImageElement[0].attribs );
	comicImage=comicImageElement[0].attribs.src;
    }

    console.log("comicImage:"+comicImage);
    //    var filename = sprintf("test%03d.png",) ; //shit didn't realize there is js implementation of sprintf but I don't wanna dl. http://www.diveintojavascript.com/projects/javascript-sprintf :(
    var filenumber=pad(counter,4);
    var filename=title+filenumber+"."+fileextension;
    if (typeof comicImage !== 'undefined') {
	var options= {url:comicImage,headers:{ 'User-Agent': 'request'} };
//	request(comicImage).pipe(fs.createWriteStream(filename)) //from  https://www.npmjs.org/package/request
	request(options).pipe(fs.createWriteStream(filename)) 
    }
};

var pad=function(num, size) { //http://stackoverflow.com/questions/2998784/how-to-output-integers-with-leading-zeros-in-javascript 
    var s = "0000" + num;
    return s.substr(s.length-size);
};

var packageIntoArchive = function() {

//from: http://stackoverflow.com/questions/5754153/zip-archives-in-node-js
    var spawn = require('child_process').spawn;
    var exec = require('child_process').exec;

    var filename="";

//http://nodejs.org/api/child_process.html


    var archivename=title+'.cbz';
    filename=title+'*.'+fileextension;
    console.log(filename);
    //    var zip = spawn('zip', ['', archivename, filename]);
    //    var zip = spawn('zip', [ archivename, filename]); //see  http://stackoverflow.com/questions/11717281/wildcards-in-child-process-spawn  , basically -->The * is being expanded by the shell, and for child_process.spawn the arguments are coming through as strings so will never get properly expanded. It's a limitation of spawn. You could try child_process.exec instead, it will allow the shell to expand any wildcards properly:
    //    var zip = spawn('zip', ['-u', archivename, filename]);
    
  
    var zip = exec('zip '+archivename+' '+ filename,function(error,stdout,stderr){
	console.log('stdout: ' + stdout);
	console.log('stderr: ' + stderr);
	if (error !== null) {
	    console.log('exec error: ' + error);
	}
    });

};


if ( 1 === 0 )
{
    var urlarraylength=urlArray.length;
for (var counter = 0; counter < urlarraylength; counter++) {
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

} else {
    var webcomicarraylength=webcomicArray.length;
    for (var counter = 0; counter < webcomicarraylength; counter++) {
	var imagecounter=0;
	var webcomic=webcomicArray[counter];
	var nextlink=webcomic.starturl;
	var title=webcomic.title;
	var baseurl=webcomic.baseurl;
	var fileextension=webcomic.fileextension;
	// console.log('----');
	// console.log(url);
	// console.log('----');
	// console.log(nextlink);


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

		    // if (counter === 19)
		    // {
		    // 	nextlink=undefined;
		    // }
		    processUrl(nextlink,counter+1);
		})
	    }
	    else { // when we finish and the last link is undefined, package up the imags into a zip file
		packageIntoArchive();
	    }
	}(nextlink,imagecounter);

    }
}

    


/**
*
This is a basic webscraper for webcomics.
It scrapes from an initial url and searches for 'next' page type indicators.
It then starts to download the image from the current page.
It also downloads the next page to scrape.
It proceeds in this fashion until the 'next' page is undefined signalling the last webcomic page.
When it is all done it zips up the images into a cbz file. 

Bugs:
currently having a hard time triggering the kickoff of the zipping
I'm trying ot trigger it when the last page is being scraped by setting a flag to true and then checking that flag on the callback of writing the image to file. I have a scoping issue. 
I'm not sure this is the best solution because right now the last two+ images will kickoff the zip process. I don't want to kick off multiple ones.
I was thiking of setting a counter that is incremented when the request for the image goes out but and checking to see if the number of completed requests equals the number of initiated requests. Hmm I suppose I could use that method in conjunction with my 'done flag' method.
*/

var request = require('request'),
cheerio = require('cheerio'),
fs = require('fs');


// to test css selectors in firebug: in console type: $$('css selector') this will return an array
// in chrome use $('') or $$('') in the console


/*
starturl: url the webcomic starts on
title: used for the temporary files and the archive
fileextension: used for temporary files
baseurl: in the case where the next link is relative, used to create a full url
engine: optional to see what type of engine the author is using.
*/

//emtpy template: {starturl:"", title:"",fileextension:"",baseurl:"",engine:"",activelyupdated:"",archiveurl:""} 
webcomicArray = [
//{starturl:"http://shiverbureau.com/2012/04/04/welcome-to-london-chapter-1-page-1/", title:"ShiverBureau",fileextension:"jpg",baseurl:"",engine:"",activelyupdated:"no"} //seems to work fine; no longer active
//http://cucumber.gigidigi.com/cq/page-498/ http://cucumber.gigidigi.com/cq/page-1/

{starturl:"http://cucumber.gigidigi.com/cq/page-1/", title:"CucumberQuest",fileextension:"jpg",baseurl:"",engine:""}, // worked fine

// test: {starturl:"http://gingerhaze.com/nimona/comic/nimona-chapter-10-page-40", title:"Nimona",fileextension:"jpg",baseurl:"http://gingerhaze.com",engine:"Drupal 7"}
{starturl:"http://gingerhaze.com/nimona/comic/page-1", title:"Nimona",fileextension:"jpg",baseurl:"http://gingerhaze.com",engine:"Drupal 7",activelyupdated:"yes"}  //get that doneFlag is undefined at the end; it is not coming up w undefined for the last page !!fix put in place
//{starturl:"http://thebbrofoz.webcomic.ws/comics/1", title:"TheBlackBrickRoadOfOZ",fileextension:"png",baseurl:"http://thebbrofoz.webcomic.ws",engine:"",activelyupdate:"yes"} 
//,{starturl:"http://www.allnightcomic.com/all-night-page-01/", title:"AllNightComic",fileextension:"jpg",baseurl:"",engine:"",activelyupdated:"no"} //last update nov 2013

//,{starturl:"http://catandgirl.com/?p=1602", title:"CatAndGirl",fileextension:"gif",baseurl:"",engine:"",activelyupdated:"yes",archive:"http://catandgirl.com/?page_id=14"} //works
//test {starturl:"http://catandgirl.com/?p=4433", title:"CatAndGirl",fileextension:"gif",baseurl:"",engine:"",activelyupdated:"yes",archiveurl:"http://catandgirl.com/?page_id=14"} 
//,{starturl:"http://www.happletea.com/2009/04/29/fallacies/", title:"HappleTea",fileextension:"jpg",baseurl:"",engine:"",activelyupdated:"",archiveurl:""}  //works.

//{starturl:"http://www.meekcomic.com/2008/12/27/chapter-1-cover/", title:"TheMeek",fileextension:"jpg",baseurl:"",engine:"",activelyupdated:"no",archiveurl:"http://www.meekcomic.com/archives/"}
];


var searchForArchiveList = function() { 
//this should work for ShiverBureau
var archiveElement=$('select');
};

//http://stackoverflow.com/questions/2998784/how-to-output-integers-with-leading-zeros-in-javascript 
var pad=function(num, size) { 
    var s = "0000" + num;
    return s.substr(s.length-size);
};

var  packageIntoArchive = function(title,fileextension) {
//from: http://stackoverflow.com/questions/5754153/zip-archives-in-node-js
//    var spawn = require('child_process').spawn;
    var exec = require('child_process').exec;
    var filename="";
//http://nodejs.org/api/child_process.html
    var archivename=title+'.cbz';
    filename='_'+title+'*.'+fileextension;
    //console.log(filename);
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

console.log('-----------------------------------------')
console.log('-----------------------------------------')
console.log(' This isn\'t being called for each object')
console.log('-----------------------------------------')
console.log('-----------------------------------------')
console.log('-----------------------------------------')



};

function WebcomicScrape(starturl,title,baseurl,fileextension) {
    this.starturl=starturl;
    this.title=title;
    this.baseurl=baseurl;
    this.fileextension=fileextension;
    this.doneFlag=false;
    this.processUrl(this.starturl,0);
}

//Javascsript 6th ed pg 204
WebcomicScrape.prototype = {
    constructor:WebcomicScrape,
    /*
     *
     *
     * Each one of the cases must work gracefully for all other webcomics. so it doesn't prevent a 
     * undefined from being set as the nextlink when the last page is handled. 
     */
    getComicImage:function($,counter,url){
	var comicImageElement;
	var comicImage;
	switch (this.title){
	case "Nimona":
	    comicImageElement=$('img[typeof="foaf:Image"]');//nimona <img typeof="foaf:Image"
	    if (typeof comicImageElement[0] !== 'undefined' && comicImageElement[0].hasOwnProperty('attribs')) {
		comicImage=comicImageElement[0].attribs.src;
	    }
	    break;
	case "ShiverBureau":
	case "HappleTea":
	case "TheMeek":
	    comicImageElement=$('#comic-1 img');
	    comicImage=comicImageElement[0].attribs.src;
	    break;

	case "CucumberQuest":
	    comicImageElement=$('#webcomic img') 
	    if (typeof comicImageElement[0] !== 'undefined' && comicImageElement[0].hasOwnProperty('attribs'))  {
		comicImage=comicImageElement[0].attribs.src;
	    }
	    break;
	case "TheBlackBrickRoadOfOZ":
	    comicImageElement=$('#comicimage'); //<img src="http://thebbrofoz.webcomic.ws/images/comics/69/a8f20b1107f89ee473a700967ea29ebb836493981.png" alt="Lions and tigers and bears" title="" id="comicimage" />
	    if (typeof comicImageElement[0] !== 'undefined' && comicImageElement[0].hasOwnProperty('attribs')) {
		comicImage=comicImageElement[0].attribs.src;
	    }
	    break;
	case "CatAndGirl":
	    comicImageElement=$('#comic > img'); //<div id="comic"> <img src="http://catandgirl.com/archive/2014-03-04-cgcraft.gif" alt="The Craft" title="The Craft" /> </div>
	    if (typeof comicImageElement[0] !== 'undefined' && comicImageElement[0].hasOwnProperty('attribs')) {
		comicImage=comicImageElement[0].attribs.src;
	    }
	    break;
	case "AllNightComic":
	    break;
	    //case "":
	    //break;
	default:
	    console.log(url+":no image found"+comicImageElement);
	}
	//	console.log("comicImage:"+comicImage);
	var filenumber=pad(counter,4);
	var imagenameonserver=function(){
	    if (typeof comicImage !== 'undefined') {
		var pathsplit=comicImage.split('/');
		console.log(pathsplit[pathsplit.length-1]);
		return pathsplit[pathsplit.length-1];
	    }
	    return "empty";
	};
	var realname = imagenameonserver();
	if ( realname === this.lastImageSaved){ //another check to prevent repeated downloading
	    this.doneFlag="duplicateImage";
	} else {
	    this.lastImageSaved=realname;
	    var filename='_'+this.title+filenumber+"."+this.fileextension;
	    console.log("doneFlag:"+this.doneFlag+' '+' ');
	    var getImage=function(comicImage,_this){
		var that=_this;
		if (typeof comicImage !== 'undefined') {
		    var imageStream=fs.createWriteStream(filename);
		    imageStream.on('close', function() {
			console.log(filename+' / '+realname+' file done');
			//create a counter such that when all the imagestreams close we write the archive, check that the nextLink is undefined 
			if (that.doneFlag===true){
			    packageIntoArchive(that.title,that.fileextension);
			    console.log("Finished scraping "+that.title+".");
			    //set that.doneFlag to prevent trying to start the process again;
			    that.doneFlag="complete"; ///hmm this may be problematic
			}else { 
			    console.log("inside;doneFlag:"+that.doneFlag+' '+' ');
			}
		    });
		    var options= {url:comicImage,headers:{ 'User-Agent': 'request'} };//request(options).pipe(fs.createWriteStream(filename)); //from  https://www.npmjs.org/package/request
		    var imagerequest =request(options,function(err,resp,body){
			if (err){
			    if (err.code === 'ECONNREFUSED'){
				console.error(url+'Refused connection');
			    } else if (err.code==='ECONNRESET'){
				console.error(url+'reset connection')
			    } else if (err.code==='ENOTFOUND'){
				console.error(url+'enotfound')
			    } else {
				console.log(url+err);
				console.log(err.stack);
			    }
			    getImage(comicImage,that.doneFlag);//call ourself again if there was an error (mostlikely due to hitting the server too hard)
			} else {
			    //do nothing
			}
		    });
		    imagerequest.pipe(imageStream);
		}
	    } ;
	    getImage(comicImage,this);
	}
    },
    getNextLink:function($,url) {
	var nextLinkElement,nextLink;

	switch (this.title) {
	case "Nimona":
	    nextLinkElement=$('li > a'); //nimona
	    //I am blatantly banking on the format not changing such that the 8th element is the <a href...> that wraps the next button
	    if (typeof nextLinkElement !== 'undefined' 
	    	&& typeof nextLinkElement[8] !== 'undefined' 
	    	&& nextLinkElement[8].hasOwnProperty('attribs')) {
	    	//		    console.log(nextLinkElement[8]);
	    	if (typeof nextLinkElement[8].attribs.hasOwnProperty('href')){
  	    	    nextLink=this.baseurl+nextLinkElement[8].attribs.href;
		}
	    }
	    break;
	case "TheBlackBrickRoadOfOZ":
	    nextLinkElement=$('.next'); //the black brick road of oz
	    if (typeof nextLinkElement !== 'undefined' 
		&& nextLinkElement[0].hasOwnProperty('attribs')
		&& nextLinkElement[0].attribs.hasOwnProperty('href')
	       ) {
  		nextLink=this.baseurl+nextLinkElement[0].attribs.href;
	    }
	    break;
case "TheMeek":
	    nextLinkElement=$('.nav-next > a'); //the black brick road of oz
	    if (typeof nextLinkElement !== 'undefined' 
		&& typeof nextLinkElement[0] !== 'undefined'
		&& nextLinkElement[0].hasOwnProperty('attribs')
		&& nextLinkElement[0].attribs.hasOwnProperty('href')
	       ) {
  		nextLink=nextLinkElement[0].attribs.href;
	    }

break;
	case "CucumberQuest":
	case "ShiverBureau":
	case "CatAndGirl":	   
	case "HappleTea":
	    nextLinkElement=$('link[rel=\'next\']'); //<link rel='next' ...>
//	    console.log(nextLinkElement);
	    if (typeof nextLinkElement !== 'undefined' 
		&& typeof nextLinkElement[0] !== 'undefined' 
		&& nextLinkElement[0].hasOwnProperty('attribs')){
		nextLink=nextLinkElement[0].attribs.href;
	    } else {console.log("hhhh");}
	    break;
	case "AllNightComic":
	    nextLinkElement=$('link[rel="next"]'); //<link rel="next" ...>
	    if (typeof nextLinkElement !== 'undefined' && typeof nextLinkElement[0] !== 'undefined' && nextLinkElement[0].hasOwnProperty('attribs')){
		nextLink=nextLinkElement[0].attribs.href;
	    }
	    break;
	case "CatAndGirl2222222":
	    nextLinkElement=$('link[rel="next"]'); //<a href="http://catandgirl.com/?p=1604" rel="next">
	    if (typeof nextLinkElement !== 'undefined' && typeof nextLinkElement[0] !== 'undefined' && nextLinkElement[0].hasOwnProperty('attribs')){
		nextLink=nextLinkElement[0].attribs.href;
	    }
	    break;
	    //case "":
	    //break;
	default:
	    console.log("No 'next link' case for this title:"+this.title);
	}
	
	//console.log(url+":No next link found");
	//	console.log("next link from currentpage:"+nextLink);

//for websites whose nextLink on the last page references itself.
	if (nextLink === this.nextLink){
	    console.log("setting this.doneFlat to complete bc nextLink repeated");
	    this.doneFlag="complete";
	}
	this.nextLink=nextLink;
	return nextLink;
    },
    processUrl:function(url,counter){
	var that = this; //needed to prevent this referring to request inside the calls
	if (typeof url !=='undefined') {
	    request(url, function(err, resp, body) {
		if (err)
		{//    			throw err;
		    if (err.code === 'ECONNREFUSED'){
			console.error(url+' Refused connection');
		    } else if (err.code==='ECONNRESET'){
			console.error(url+' reset connection')
		    } else if (err.code==='ENOTFOUND'){
			console.error(url+' enotfound')
		    } else{
			console.log(url+err);
			console.log(err.stack);
		    }
		}
		//		    console.log(err);

		if (that.doneFlag===false) {
		//if there aren't any errors we proceed w extraction
		    if (typeof err==='undefined'
			|| err===null){
			var $ = cheerio.load(body); //hmm so $ is global??
			//	    console.log(counter);
			
			var nextlink=that.getNextLink($,url);
			//	    console.log(nextlink)
			that.getComicImage($,counter,url);

			that.processUrl(nextlink,counter+1);
		    }else if (typeof err!=='undefined') {
			//			console.log(err.code);
			//wait 0.25 sec before tryiing again
			setTimeout(function() {
			    that.processUrl(url,counter);
			},250);//could make this timeout wait longer the more frq the reset connections happen
		    }
		} else if (that.doneFlag==="duplicateImage"){
		    that.processUrl(undefined,counter+1);
		}
		
		
	    })
	}
	else { // when we finish and the last link is undefined, package up the images into a zip file
	    that.doneFlag=true; //may also be triggered if the image name we are trying to download is the same as the last one.
	    console.log("setting doneFlag:"+that.doneFlag);
	    // setTimeout(function(){
	    // 	packageIntoArchive(that.title,that.fileextension);
	    // 	console.log("Finished scraping "+that.title+".");
	    // },2500); //this is a hack as large images may take longer or if net work traffic is bad this may attempt to archive before all files are downloaded --> moved to flag and performing check when images downloaded
	}
    }
};

function Main() {
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

console.log("Launching for "+title+"."); 
	var wcs = new WebcomicScrape(nextlink,title,baseurl,fileextension);


	// !function processUrl (url,counter){
	//     if (typeof url !=='undefined') {
	// 	request(url, function(err, resp, body) {
	// 	    if (err)
    	// 		throw err;
	// 	    var $ = cheerio.load(body); //hmm so $ is global??
	// 	    //	    console.log(counter);
		    
	// 	    nextlink=wcs.getNextLink($);
	// 	    //	    console.log(nextlink)
	// 	    wcs.getComicImage($,counter);

	// 	    // if (counter === 19)
	// 	    // {
	// 	    // 	nextlink=undefined;
	// 	    // }
	// 	    processUrl(nextlink,counter+1);
	// 	})
	//     }
	//     else { // when we finish and the last link is undefined, package up the imags into a zip file
	// 	packageIntoArchive(wcs.title,wcs.fileextension);
	//     }
	// }(nextlink,imagecounter);

    }


    

}

Main();

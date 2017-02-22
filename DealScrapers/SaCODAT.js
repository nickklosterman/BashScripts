var http = require('http');
fs = require('fs');

var url='http://www.steepandcheap.com/data/odat.json'

//curl 'http://www.steepandcheap.com/data/odat.json'
//-H 'Host: www.steepandcheap.com'
//-H 'User-Agent: Mozilla/5.0 (X11; Linux i686; rv:51.0) Gecko/20100101 Firefox/51.0'
//-H 'Accept: application/json, text/javascript, */*; q=0.01'
//-H 'Accept-Language: en-US,en;q=0.5'
//-H 'Accept-Encoding: gzip, deflate'
//-H 'X-Requested-With: XMLHttpRequest'
//-H 'Referer: http://www.steepandcheap.com/'
    //-H 'Cookie: s_fid=7A275E1BB218329A-3BC35CD263785055; s_cpm=%5B%5B%27Direct%2520Load%27%2C%271480293855019%27%5D%2C%5B%27Direct%2520Load%27%2C%271480294263043%27%5D%2C%5B%27Direct%2520Load%27%2C%271480552233993%27%5D%2C%5B%27Direct%2520Load%27%2C%271481682632258%27%5D%2C%5B%27Direct%2520Load%27%2C%271487725368959%27%5D%5D; s_vi=[CS]v1|2B8D3A738507AC16-4000010A000021EE[CE]; sac_atg_visited=1; kampyle_userid=a7e8-83db-0a43-2f6c-13bd-6d96-d133-23ee; kampyleUserSession=1487725377941; kampyleSessionPageCounter=6; kampyleUserSessionsCount=13; cd_user_id=1543f57ee538-0abfa3b98670708-7020215a-1aeaa0-1543f57ee548d; optimizelyEndUserId=oeu1461351600265r0.15810536039296497; __bcscm=EBS; optimizelyBuckets=%7B%225018395040%22%3A%225013554083%22%2C%225615390117%22%3A%225615350137%22%7D; optimizelySegments=%7B%223473690778%22%3A%22direct%22%2C%223483930729%22%3A%22ff%22%2C%223490350708%22%3A%22false%22%2C%223490460744%22%3A%22none%22%7D; optimizelySegments=%7B%223473690778%22%3A%22direct%22%2C%223483930729%22%3A%22ff%22%2C%223490350708%22%3A%22false%22%2C%223490460744%22%3A%22none%22%7D; optimizelyBuckets=%7B%225018395040%22%3A%225013554083%22%2C%225615390117%22%3A%225615350137%22%2C%226826420769%22%3A%226820110874%22%2C%227636762708%22%3A%227650151772%22%2C%228158871714%22%3A%228163252256%22%2C%228231945512%22%3A%228237168237%22%7D; __utma=50154468.2080371419.1480293860.1487725374.1487727382.6; __utmz=50154468.1480293860.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); cartCount=0; BC_CSESSION=1b0382ee1d59de5d19c3a3791b41756b131880c8; s_cc=true; RT="sl=1&ss=1487727423082&tt=4609&obo=0&bcn=%2F%2F3409b6b0.mpstat.us%2F&sh=1487729619578%3D1%3A0%3A4609&dm=www.steepandcheap.com&si=063d0bc8-7e01-4a33-89cc-b62531e45ec0&ld=1487729619579"; __utmc=50154468; c49=Home; productCompare=; __utmb=50154468.5.10.1487727382; s_sq=%5B%5BB%5D%5D; JSESSIONID=PRvG6jGHIPCd8AGbjembeXhF.prodc1_public_8180; BC_USR=%7B%22displayName%22%3Anull%2C%22id%22%3A%222832026912%22%2C%22emailHash%22%3A%22%22%2C%22loggedIn%22%3Afalse%2C%22recognized%22%3Afalse%2C%22registered%22%3Afalse%2C%22explicitOrAutoLoggedIn%22%3Afalse%2C%22imagePath%22%3Anull%2C%22login%22%3Anull%2C%22syncedWithStrava%22%3Afalse%7D; BIGipServerprod-c1-atg=673065482.62495.0000; OmnitureEntryPage=%5EHome'

var options = {
    hostname:'www.steepandcheap.com',
    port: '80',
    path: '/data/odat.json',
    headers:{
	'Cookie': 's_fid=7A275E1BB218329A-3BC35CD263785055; s_cpm=%5B%5B%27Direct%2520Load%27%2C%271480293855019%27%5D%2C%5B%27Direct%2520Load%27%2C%271480294263043%27%5D%2C%5B%27Direct%2520Load%27%2C%271480552233993%27%5D%2C%5B%27Direct%2520Load%27%2C%271481682632258%27%5D%2C%5B%27Direct%2520Load%27%2C%271487725368959%27%5D%5D; s_vi=[CS]v1|2B8D3A738507AC16-4000010A000021EE[CE]; sac_atg_visited=1; kampyle_userid=a7e8-83db-0a43-2f6c-13bd-6d96-d133-23ee; kampyleUserSession=1487725377941; kampyleSessionPageCounter=6; kampyleUserSessionsCount=13; cd_user_id=1543f57ee538-0abfa3b98670708-7020215a-1aeaa0-1543f57ee548d; optimizelyEndUserId=oeu1461351600265r0.15810536039296497; __bcscm=EBS; optimizelyBuckets=%7B%225018395040%22%3A%225013554083%22%2C%225615390117%22%3A%225615350137%22%7D; optimizelySegments=%7B%223473690778%22%3A%22direct%22%2C%223483930729%22%3A%22ff%22%2C%223490350708%22%3A%22false%22%2C%223490460744%22%3A%22none%22%7D; optimizelySegments=%7B%223473690778%22%3A%22direct%22%2C%223483930729%22%3A%22ff%22%2C%223490350708%22%3A%22false%22%2C%223490460744%22%3A%22none%22%7D; optimizelyBuckets=%7B%225018395040%22%3A%225013554083%22%2C%225615390117%22%3A%225615350137%22%2C%226826420769%22%3A%226820110874%22%2C%227636762708%22%3A%227650151772%22%2C%228158871714%22%3A%228163252256%22%2C%228231945512%22%3A%228237168237%22%7D; __utma=50154468.2080371419.1480293860.1487725374.1487727382.6; __utmz=50154468.1480293860.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); cartCount=0; BC_CSESSION=1b0382ee1d59de5d19c3a3791b41756b131880c8; s_cc=true; RT="sl=1&ss=1487727423082&tt=4609&obo=0&bcn=%2F%2F3409b6b0.mpstat.us%2F&sh=1487729619578%3D1%3A0%3A4609&dm=www.steepandcheap.com&si=063d0bc8-7e01-4a33-89cc-b62531e45ec0&ld=1487729619579"; __utmc=50154468; c49=Home; productCompare=; __utmb=50154468.5.10.1487727382; s_sq=%5B%5BB%5D%5D; JSESSIONID=PRvG6jGHIPCd8AGbjembeXhF.prodc1_public_8180; BC_USR=%7B%22displayName%22%3Anull%2C%22id%22%3A%222832026912%22%2C%22emailHash%22%3A%22%22%2C%22loggedIn%22%3Afalse%2C%22recognized%22%3Afalse%2C%22registered%22%3Afalse%2C%22explicitOrAutoLoggedIn%22%3Afalse%2C%22imagePath%22%3Anull%2C%22login%22%3Anull%2C%22syncedWithStrava%22%3Afalse%7D; BIGipServerprod-c1-atg=673065482.62495.0000; OmnitureEntryPage=%5EHome',
	
	'User-Agent': 'Mozilla/5.0 (X11; Linux i686; rv:51.0) Gecko/20100101 Firefox/51.0',
	'Accept': 'application/json, text/javascript, */*; q=0.01',
	//'Accept-Encoding': 'gzip, deflate',
	'Accept-Language': 'en-US,en;q=0.5',
	'X-Requested-With': 'XMLHttpRequest',
 'Referer': 'http://www.steepandcheap.com/'	
    }
}



http.get(options, (res) => {
    var body = '';
    // consume response body
    res.on('data',function(data) {
	body +=data; 
    });
    res.on('end',function() {
	var jsonBody = JSON.parse(body);
	delete jsonBody.upcoming;
//	console.log(jsonBody);
	console.log(JSON.stringify(jsonBody));
    });
    res.resume();
}).on('error', (e) => {
    console.log(`Got error: ${e.message}`);
});

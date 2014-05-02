var request = require("request"),
cheerio = require("cheerio"); 


    request("https://www.deviantart.com/users/login", function(err,res,body) {
	//if (body) console.log(body);
	if (err) console.log(err);
	//    var foo=body.find("validate_token");
	var $ = cheerio.load(body);
	var validate_token_element=$('input[name="validate_token"]');
	var validate_key_element=$('input[name="validate_key"]');
	console.log(validate_token_element[0].attribs.value+" -**- "+validate_key_element[0].attribs.value);
	logMeIn(validate_token_element[0].attribs.value,validate_key_element[0].attribs.value);

	//console.log(validate_token_element);
	//console.log(validate_key_element);
    });
var logMeIn = function(token,key) {
var options = {
    url: 'https://www.deviantart.com/users/login',
    headers: {
        'User-Agent': 'Mozilla'
    }, 
    qs: {
	ref:"https://www.deviantart.com/users/loggedin",
	username: "bithynia", 
	password: "fluorescenthell",
	remember_me:1, 
	validate_token:token,//"b227afe808facd33c0f4", //this and the value below come from the 
	validate_key:key //"1398994345"}
}
};
//request.post({url: "https://www.deviantart.com/users/login", qs: {ref:"http://www.deviantart.com", remember_me:1, username: "bithynia", password: "fluorescenthell",validate_token:"b227afe808facd33c0f4",validate_key:"1398994345"}}, function(err, res, body) {
    request.defaults({jar:true}).post(options, function(err,res,body){
	if(err) {
            return console.error("err1:"+err);
	}
	var options ={
	    url:"http://bithynia.deviantart.com/art/Eric-Canete-s-Eve-425888291",
	    headers:{
		'User-Agent': 'Mozilla'
	    }
	};
	
	request.get(options, function(err, res, body) {
            if(err) {
		return console.error("err2:"+err);
            }
	    
            console.log("Got a response!", res);
            console.log("Response body:", body);
	});
    });
}

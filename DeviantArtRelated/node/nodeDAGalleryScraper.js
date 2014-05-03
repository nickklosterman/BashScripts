#!/usr/bin/env node
var request = require("request"),
cheerio = require("cheerio"); 

var myjar = request.jar();

console.log("user:"+process.argv[2]+" password:"+process.argv[3]);

//find the token and key to pass for logging in
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
            'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36'
        }, 
        qs: {
            ref:"https://www.deviantart.com/users/loggedin",
            username: process.argv[2], 
            password: process.argv[3],
            remember_me:"1", 
            validate_token:token,//"b227afe808facd33c0f4", //this and the value below come from the 
            validate_key:key //"1398994345"}
        }
    };
    //request.post({url: "https://www.deviantart.com/users/login", qs: {ref:"http://www.deviantart.com", remember_me:1, username: "uuuu", password: "ppppp",validate_token:"b227afe808facd33c0f4",validate_key:"1398994345"}}, function(err, res, body) {


    request = request.defaults({jar:true});
    //request.defaults({jar:true}).post(options, function(err,res,body){
    request.post(options, function(err,res,body){
        if(err) {
            return console.error("err1:"+err);
        }

        if (res) {
        //scroll through the response
        //     for (var item in res)
        //     {
	// 	console.log(item)
	//     }
	    console.log(res.headers); // I see only 1 cookie comeback in the response headers whereas the response headers in chrome have 3 
console.log(res);
        }

        var options ={
            url:"http://bithynia.deviantart.com/art/Eric-Canete-s-Eve-425888291",
            headers:{
                'User-Agent': 'Mozilla'
            }
        };
        
        // request.get(options, function(err, res, body) {
        //     if(err) {
        //         return console.error("err2:"+err);
        //     }
            
        //     console.log("Got a response!", res);
        //     console.log("Response body:", body);
        // });
    });
}


/*
Connection:Keep-Alive
Content-Length:0
Content-Type:text/html
Date:Fri, 02 May 2014 19:58:39 GMT
Keep-Alive:timeout=45
Location:https://www.deviantart.com/users/loggedin
P3P:policyref="/w3c/p3p.xml", CP="NOI DSP COR CURa OUR STP"
Server:Apache
Set-Cookie:auth=__54c9efa8a7112c39a358%3B%22302dbe03eaa15d36295fea5c6d62efcb%22; expires=Sun, 01-Jun-2014 19:58:39 GMT; path=/; domain=.deviantart.com; httponly
Set-Cookie:auth_secure=__a8c293b164d41621e2f8%3B%220182f47b8957051b7e6f3546d8ef79ef%22; expires=Fri, 01-Jan-2038 08:00:00 GMT; path=/; domain=.deviantart.com; secure; httponly
Set-Cookie:userinfo=__9aa2f0af24dc799ef301%3B%7B%22username%22%3A%22Bithynia%22%2C%22uniqueid%22%3A%22c664d78d69b6f8ced2841134a3330ab5%22%2C%22vd%22%3A%221399060506%2C1399060506%2C1399060693%2C7%2C0%2C%2C1%2C0%2C1%2C1399060506%2C1399060693%2C4%2C4%2C0%2C1399060683%2C4%22%7D; expires=Sun, 01-Jun-2014 19:58:39 GMT; path=/; domain=.deviantart.com
Set-Cookie:features=deleted; expires=Thu, 02-May-2013 19:58:38 GMT; path=/; domain=.deviantart.com
*/


//how would I manually set the cookie data with what was passed back above?
// var j = request.jar()
// var cookie = request.cookie('your_cookie_here')
// j.setCookie(cookie, uri);
// request({url: 'http://www.google.com', jar: j}, function () {
//   request('http://images.google.com')
// })

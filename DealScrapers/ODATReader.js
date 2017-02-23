var fs = require('fs');

function main() {
    if (process.argv.length <= 2) {
	console.log("Usage: " +__filename);
	process.exit(-1);
    }
    var cliArgs = process.argv.slice(2),
	jsonData;
    if(cliArgs.length > 0 ) {
	getData(cliArgs[0]).then(function(data){
	    jsonData = JSON.parse(data);
	    var fields = ['brandName',
			  'productTitle',
			  'listPrice',
			  'maxSalePrice',
			  'salePrice'];
	    printOut(jsonData,fields);
	},function() {
	    console.log("FML");
	});
    }
}

function getData(filename) {
    return new Promise(function(resolve, reject){
	fs.readFile(filename,'utf8',function(err,data) {
	    if (err) {
		reject(err);
	    } else { resolve(data);
		   }
	});
    });
}

function printOut(data,fieldsArray){
    var output="", i=0;
    for (i=0;i<fieldsArray.length; i++) {
	output+=fieldsArray[i]+":"+data[fieldsArray[i]]+" \t ";
    }
    if (data.upcoming) {
	for (i=0;i<data.upcoming.length; i++){
	    printOut(data.upcoming[i],fieldsArray);
	}
    }
    console.log(output);
}

main();

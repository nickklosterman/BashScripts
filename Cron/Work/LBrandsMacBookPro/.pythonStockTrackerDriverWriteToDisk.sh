#!/bin/bash

pushd .
cd /Users/nklosterman/.personal/StockTrackerOutput
/usr/local/bin/python3 /Users/nklosterman/.personal/nickGit/PythonStockTracker/StockTrackerJSON.py -i /Users/nklosterman/.personal/nickGit/configfiles/StockTrackerJSON/AllPortfolios.json -t /Users/nklosterman/.personal/nickGit/PythonStockTracker/TaxBracket.txt -s
# the -s option writes the value out to disk
#I removed -w (web) oiptoin since we have a separate script doing that.....which fuck is just duplicating the same calls and work. 
#open AllPortfolios.html; 
popd

# python3 /Users/nklosterman/.personal/nickGit/PythonStockTracker/StockTrackerJSON.py -i /Users/nklosterman/.personal/nickGit/configfiles/StockTrackerJSON/AllPortfolios.json -w -t /Users/nklosterman/.personal/nickGit/PythonStockTracker/TaxBracket.txt
# echo $DJINNIUS_HOST
# ftp -in $DJINNIUS_HOST <<EOF
# user $DJINNIUS_USER $DJINNIUS_PASSWORD
# lcd "${LocalFilePath}"
# binary
# put "${Filename}"
# quit
# EOF

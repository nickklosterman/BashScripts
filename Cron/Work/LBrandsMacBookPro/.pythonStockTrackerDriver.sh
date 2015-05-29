#!/bin/bash

pushd .
cd /private/tmp
/usr/local/bin/python3 /Users/nklosterman/.personal/nickGit/PythonStockTracker/StockTrackerJSON.py -i /Users/nklosterman/.personal/nickGit/configfiles/StockTrackerJSON/AllPortfolios.json -w -t /Users/nklosterman/.personal/nickGit/PythonStockTracker/TaxBracket.txt
/usr/local/bin/python3 /Users/nklosterman/.personal/nickGit/PythonStockTracker/StockTrackerJSON.py -i /Users/nklosterman/.personal/nickGit/configfiles/StockTrackerJSON/Roommates.json -w -t /Users/nklosterman/.personal/nickGit/PythonStockTracker/TaxBracket.txt 
popd

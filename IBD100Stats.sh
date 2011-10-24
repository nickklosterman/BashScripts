#!/bin/bash

#get list of all stock symbols
#get current quote of all stock symbols
#compare current quote to past quote when on IBD100 List
# loop over mysql output
# grep appropriate line in quote file
# parse out price
# perform math calc using bc
# printout comparison line by line

if [ $# -lt 0 ]
then
    echo "scriptname.sh directions;"
else
    mysql --skip-column-names -s --database StockMarketData -e "select distinct symbol from IBD100 order by symbol asc" -p > /tmp/IBD100stocks.txt
    stocklist=$(cat /tmp/IBD100stocks.txt | tr "\n" "+" )
    wget "http://download.finance.yahoo.com/d/quotes.csv?s=${stocklist}&f=sl1&e=csv" -O /tmp/quotes.csv -nv
    
    cat /tmp/quotes.csv
    
    while read Line
    do
#echo ${Line}
	symbol=$( echo ${Line} | cut -d "," -f 1  )
	mostrecentclosingprice=$( echo ${Line} | cut -d "," -f 2  )
#min,max()
	query="select avg(ClosingPrice) from IBD100 where Symbol=${symbol}";
#--> either need to execute 1 query for each symbol or need another db that holds only 1price for each symbol and then just dump the data from that table. maybe do both and see what time diff is btw methods.
	echo ${symbol} ${mostrecentclosingprice}
	echo ${query}
    done < /tmp/quotes.csv
    
#http://www.gummy-stuff.org/Yahoo-data.htm or put in spreadsheet and do it that way
#http://www.gummy-stuff.org/SP500-stuff.htm	
#    done
    
fi
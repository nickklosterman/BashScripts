#!/bin/bash

if [ $# -lt 1 ]
then
    echo "scriptname.sh directions;"
else
    if [ -f "$1" ] #if we specified a file on the command line then read the file and spit it out else parse args as stock tickers
    then
	while read LINE
	do
	    ticker=$(echo "$LINE" | tr '[a-z]' '[A-Z]' )
	    QueryForQuote $ticker
	done < "$1"
    else 
	until [ -z "$1" ] #parse args as stock tickers
	do
	    ticker=$(echo "$1" | tr '[a-z]' '[A-Z]' )
	    QueryForQuote $ticker
#	    symbol=$1
#	url="'http://download.finance.yahoo.com/d/quotes.csv?s=${symbol}&f=l1'"
#echo $url
#	    quote=$(curl -s "http://download.finance.yahoo.com/d/quotes.csv?s=${symbol}&f=l1" | sed 's/.$//' ) #the trailing sed command strips a ^M that was at the end of each quote price
#	    if [ $quote == "0.00" ]
#	    then 
#		echo "uh oh!"
#	    fi
#	    echo ${symbol} ${quote}
	    shift
	done 
	
	echo "could check if the cli arg is a file and attempt to open otherwise treat as a stock symbol and do a query"
    fi
fi

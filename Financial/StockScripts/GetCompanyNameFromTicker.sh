#!/bin/bash
function GiveWebpageReturnStockTitle()
{
    webpage="$1"
    TitleLine=$(grep "<title>" $webpage | sed 's/<[^>]*>//g;s/- Yahoo! Finance//;s/Summary for //g' )
#Title=$(grep "<title>" $webpage  )
    CompanyName=$(grep "<div class=\"title\">" $webpage | sed 's/.*<h2>//g;s/<\/h2>.*//;')
#    if [ "$TitleLine" == "    Symbol Lookup from Yahoo! Finance" ]
    if  grep -q "Symbol Lookup from" <<< "$TitleLine"
    then
	CompanyName="FAIL"
	TitleLine="FAIL"
    else
#echo "++$CompanyName++" "(($TitleLine))"
	if [ "${#CompanyName}" -lt 5 ] # if variable length is less than 5 then we proly have a blank document, send signal to retry
	then
	    TitleLine="BLANK"
	fi
    fi

    echo "$TitleLine"
}

function GetCompanyName()
{
    TickerCompany="BLANK"

    while [ "$TickerCompany" == "BLANK" ] #Loop until we get a valid response
    do
	wget -O /tmp/TickerCheck -q "http://finance.yahoo.com/q?s=$1"
	TickerCompany=$( GiveWebpageReturnStockTitle /tmp/TickerCheck )
#	echo -n "$TickerCompany."
    done

    if [ "$TickerCompany" == "FAIL" ] || [ "$TickerCompany" == "BLANK" ]
    then
	echo "Company for ticker $1 not found"
	echo "$1" >> "$3"
    elif [ "$TickerCompany" != "BLANK" ]
    then
	#echo ""
	echo "$TickerCompany" >> "$2"
    fi
#    echo "$TickerCompany"
}

function FileMaintenance()
{
    if [ -e "$1" ]
    then 
	echo "Deleting $1"
	rm "$1"
    fi
}

###Main###
output="TickerCompanyName.txt"
outputnotfound="TickerNotFound.txt"
Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then
    echo "Usage: VerifyStockTickers ticker <ticker> ...."
    echo "Usage: VerifyStockTickers file"
else

    FileMaintenance "$output"
    FileMaintenance "$outputnotfound"

    if [ -f "$1" ] #if its a file then read the file checking the tickers on each line
    then 
	while read LINE
	do
	    GetCompanyName "$LINE" "$output" "$outputnotfound" #add as args output file names
	done < "$1"
	
    else
	
	until [ -z "$1" ] 
	do
	    GetCompanyName "$1"  "$output" "$outputnotfound" #add as args output file names
	    shift 
	done
    fi
fi

echo "Could I just perform a query and then pipe that to the script?"
if [ -e TickerNotFound.txt ]
then
    less TickerNotFound.txt
fi
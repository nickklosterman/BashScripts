#!/bin/bash
function GiveWebpageReturnStockTitle()
{
    webpage="$1"
    TitleLine=$(grep "<title>" $webpage | sed 's/<[^>]*>//g;s/- Yahoo! Finance//;s/Summary for //g' )
#Title=$(grep "<title>" $webpage  )
    CompanyName=$(grep "<div class=\"title\">" $webpage | sed 's/.*<h2>//g;s/<\/h2>.*//;')
    if [ "$TitleLine" == "    Symbol Lookup from Yahoo! Finance" ]
    then
	CompanyName="FAIL"
    else

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

    if [ "$TickerCompany" != "FAIL" ]
    then
	#echo ""
	echo "$TickerCompany" >> "$2"
    else
	echo "Company for ticker $1 not found"
	echo "$1" >> "$3"
    fi

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
else

    FileMaintenance "$output"
    FileMaintenance "$outputnotfound"

    until [ -z "$1" ] 
    do
	GetCompanyName "$1"  "$output" "$outputnotfound" #add as args output file names
	shift 
    done

fi
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
	echo -n "$TickerCompany." #show some sort of progress 
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
#due to this function being called so we can grab its output you can't echo out debug stuff and see them!
    file="$1"
    if [ -e "$file" ]
    then 
	read -p "$file exists. Would you like to overwrite its contents? (y/n)" yesno
	while [ ! "$yesno" == "y" ] && [ ! "$yesno" == "n" ]
	do
	    read -p "Please answer with a y or n:" yesno
	done
	if [ "$yesno" == "y" ]
	then
	    echo "Deleting $file"
	    rm "$file"
	elif [ "$yesno" == "n" ]
	then
	    read -p "Please enter a new filename for the output to be written to:" file
	fi
    fi
    echo $file
}

###Main###
output="TickerCompanyNameV2.txt"
outputnotfound="TickerNotFoundV2.txt"
Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then
    echo "Usage: VerifyStockTickers ticker <ticker> ...."
    echo "Usage: VerifyStockTickers file"
    echo "When specifiying a file, commented lines and lines starting with dates will be ignored. Tickers on a single line separated by spaces will be tokenized for sorting."
else
output=$( FileMaintenance "$output" )
outputnotfound=$( FileMaintenance "$outputnotfound" )

    if [ -f "$1" ] #if its a file then read the file checking the tickers on each line
    then 
	filename="/tmp/sortedtickers"
	grep -v "#" ${1} | grep -v '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' | tr ' ' '\n' | sort | uniq > ${filename}
	while read LINE
	do
	    GetCompanyName "$LINE" "$output" "$outputnotfound" #add as args output file names
	done < "${filename}"
	
    else
	
	until [ -z "$1" ] 
	do
	    GetCompanyName "$1"  "$output" "$outputnotfound" #add as args output file names
	    shift 
	done
    fi
echo "Is there a bulk method as it takes forever to do it one by one??? yes, I did it elsewhere but then you'd have to parse later to separate good from bad.(I think)"
fi

echo "Could I just perform a query and then pipe that to the script?"
if [ -e TickerNotFound.txt ]
then
    less TickerNotFound.txt
fi

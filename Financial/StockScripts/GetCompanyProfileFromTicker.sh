#!/bin/bash
function GiveWebpageReturnStockInfo()
{
    webpage="$1"
    TitleLine=$(grep "<title>" $webpage | sed 's/<[^>]*>//g;s/- Yahoo! Finance//' )
    CompanyInfo=$(grep "<span class=\"yfi-module-title\">Business Summary</span>" $webpage | sed 's/.*<\/th><\/tr><\/table><p>//;s/<\/p><p><a href=\"\/q\/ks.*//;s/\xc3\x82\xc3\x92/\x27/g' )
    # in less the unicdoe apostrophe (I think that is what it is) was showing up as Â<U+0092>, in emacs it was showing up as \222, I ended up looking for the hex of it using ghex
    if [ "$TitleLine" == "    Symbol Lookup from Yahoo! Finance" ]
    then
	CompanyInfo="FAIL"
    fi
    echo "$CompanyInfo"
}

function GetCompanyInfo()
{
    wget -O /tmp/TickerCheck -q "http://finance.yahoo.com/q/pr?s=$1+Profile"
    TickerCompany=$( GiveWebpageReturnStockInfo /tmp/TickerCheck )
    if [ "$TickerCompany" != "FAIL" ]
    then
	echo -e "$1:$TickerCompany \n"

    else
	echo "Company for ticker $1 not found"
    fi
}


function GetCompanyInfoFileOutput()
{
    TickerCompany="BLANK"

    while [ "$TickerCompany" == "BLANK" ] #Loop until we get a valid response
    do
	wget -O /tmp/TickerCheck -q "http://finance.yahoo.com/q/pr?s=$1+Profile"
	TickerCompany=$( GiveWebpageReturnStockInfo /tmp/TickerCheck )
	echo -n "$1 " #$TickerCompany" #show some sort of progress 
    done

    if [ "$TickerCompany" == "FAIL" ] || [ "$TickerCompany" == "BLANK" ]
    then
	echo "Company for ticker $1 not found"
	echo "$1" >> "$3"
    elif [ "$TickerCompany" != "BLANK" ]
    then
	echo "" >> "$2"
	echo "${1}" >> "$2"
	echo "$TickerCompany" >> "$2"
#	echo "$TickerCompany" 
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
	    #	    echo "Deleting $file"  #since you "return" things in bash with echo, this was being put in the output
	    rm "$file"

	elif [ "$yesno" == "n" ]
	then
	    read -p "Please enter a new filename for the output to be written to:" file
	fi
    fi
    echo $file
}



###Main###

output="TickerCompanyProfile.txt"
outputnotfound="TickerNotFound.txt"
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
	filename="${1}"

	while read LINE
	do
#	    echo "$LINE"
	    GetCompanyInfoFileOutput "$LINE" "$output" "$outputnotfound" #add as args output file names
	done < "${filename}"
	
    else #if we just threw a couple of tickers on the command line, loop over them outputting the data to screen
	
	until [ -z "$1" ] 
	do
	    GetCompanyInfo "$1"  
	    shift 
	done
    fi
    echo "Is there a bulk method as it takes forever to do it one by one??? yes, I did it elsewhere but then you\'d have to parse later to separate good from bad.(I think)"
fi

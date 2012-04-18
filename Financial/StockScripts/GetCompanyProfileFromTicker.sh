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

###Main###
Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then
    echo "Usage: VerifyStockTickers ticker <ticker> ...."
else

until [ -z "$1" ] 
do
GetCompanyInfo "$1"
shift 
done

fi
#!/bin/bash
function GiveWebpageReturnStockTitle()
{
webpage="$1"
TitleLine=$(grep "<title>" $webpage | sed 's/<[^>]*>//g;s/- Yahoo! Finance//' )
CompanyName=$(grep "<div class=\"title\">" $webpage | sed 's/.*<h2>//g;s/<\/h2>.*//' )
if [ "$TitleLine" == "    Symbol Lookup from Yahoo! Finance" ]
then
CompanyName="FAIL"
fi
echo "$CompanyName"
}

function GetCompanyName()
{
wget -O /tmp/TickerCheck -q "http://finance.yahoo.com/q?s=$1"
TickerCompany=$( GiveWebpageReturnStockTitle /tmp/TickerCheck )
if [ "$TickerCompany" != "FAIL" ]
then
echo "$TickerCompany"
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
GetCompanyName "$1"
shift 
done

fi
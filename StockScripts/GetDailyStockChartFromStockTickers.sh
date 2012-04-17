#!/bin/bash

#Other possible sources, usatoday,bloomberg,nyse,nasdaq, cbs marketwatch
#if stock on nasdaq vs nyse then need that to appropriately query the correct domain
#perform computer vision on chart?

function GetCharts()
{
#check out the resources guy. instead of command line options, use 'dialog' to prompt and process as a simple gui


#default thumbnail on front page
echo "http://chart.finance.yahoo.com/t?s=$1&lang=en-US&region=US&width=300&height=180" >> "$2"

##Chart Style (q) variable: b:bar c:candle
##Log/Linear (l) variable: on:log off:linear
##Chart Size (z) variable: m:medium 512x288px l:large 800x475px
##Compare to (c) variable: ^GSPC (S&P500),^IXIC(NASDAQ),^DJI(DOQ),any stock ticker
#Line style (default)
echo "http://chart.finance.yahoo.com/z?s=$1&t=1y&q=&l=&z=l&a=v&p=s&lang=en-US&region=US" >> "$2"
echo "http://chart.finance.yahoo.com/z?s=$1&t=6m&q=&l=&z=l&a=v&p=s&lang=en-US&region=US" >> "$2"
echo "http://chart.finance.yahoo.com/z?s=$1&t=3m&q=&l=&z=l&a=v&p=s&lang=en-US&region=US" >> "$2"
echo "http://chart.finance.yahoo.com/z?s=$1&t=5dm&q=&l=&z=l&a=v&p=s&lang=en-US&region=US" >> "$2"
echo "http://chart.finance.yahoo.com/z?s=$1&t=1dm&q=&l=&z=l&a=v&p=s&lang=en-US&region=US" >> "$2"

#Bar Style
#http://chart.finance.yahoo.com/z?s=UBNT&t=1d&q=b&l=on&z=l&a=v&p=s&lang=en-US&region=US
#Candle Style
#http://chart.finance.yahoo.com/z?s=UBNT&t=1d&q=c&l=on&z=l&a=v&p=s&lang=en-US&region=US
#Compare stock to: can compare up to 10 items to the stock
#http://chart.finance.yahoo.com/z?s=UBNT&t=3m&q=c&l=off&z=m&c=^GSPC,^IXIC,^DJI,CMG,AAPL&a=v&p=s&lang=en-US&region=US

}

###Main###
Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then
    echo "Usage: VerifyStockTickers ticker <ticker> ...."
else

outputfilename="/tmp/Charts" #"$2"
if [ -e "$outputfilename" ]
then
rm "$outputfilename"
fi


until [ -z "$1" ] 
do
GetCharts "$1" "$outputfilename"
shift 
done

feh -f /tmp/Charts

fi
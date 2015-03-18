#!/bin/bash

keyword=$1

#echo "${1} ${2}"
case $1 in
    "Columbus")
        keyword="CENTRAL"
        zone="OHZ055"
        ;;
    "Dayton")
        keyword="SOUTHWEST"
        zone="OHZ061"
        ;;
    *)
        echo "Usage: $0 {Columbus|Dayton}"
#        echo "bash WeatherText.sh City"
#        echo "bash WeatherText.sh Columbus"
#        echo "bash WeatherText.sh Dayton"
        
        exit 1
        ;;
esac

wget -q "http://www.nws.noaa.gov/view/prodsByState.php?state=OH&prodtype=hourly" -O /tmp/currentconditions.html && grep -A 10 -m 2 $keyword /tmp/currentconditions.html  #| sed -n -e '3p' -e '7p' -e '8p' -e '9p'
#sed -n -e '3p' -e '7p' -e '8p' -e '9p' ==> only print the 3rd,7th,8th and 9th line
echo "--------============----------"
# on the mac I had to do -m 2 (stop after max count reached) otherwise I didn't get any text output

# I believe that the weather format changed in ~2014/2015 such that the text weather is no longer simply raw text.
#wget -q "http://forecast.weather.gov/MapClick.php?zoneid=${zone}&TextType=1" -O /tmp/fc.html && awk '/${zone}/{found=1} found{print; if(/\$\$/) exit}' /tmp/fc.html 

grep "able><table" /tmp/fc.html -A 15 | sed 's/<[^>]*>//g'

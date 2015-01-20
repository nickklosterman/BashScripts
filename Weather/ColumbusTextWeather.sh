#!/bin/bash

#good set of text weather resources: http://www.nws.noaa.gov/view/states.php?state=OH
wget -q "http://www.nws.noaa.gov/view/prodsByState.php?state=OH&prodtype=hourly" -O /tmp/currentconditions.html && grep -A 10 -m 1 CENTRAL /tmp/currentconditions.html  #| sed -n -e '3p' -e '7p' -e '8p' -e '9p'
#sed -n -e '3p' -e '7p' -e '8p' -e '9p' ==> only print the 3rd,7th,8th and 9th line
echo "--------============----------"
# on the mac I had to do -m 2 (stop after max count reached) otherwise I didn't get any text output
#wget -q "http://www.nws.noaa.gov/view/prodsByState.php?state=OH&prodtype=zone" -O /tmp/fc.html && grep -A 28 -m 1 OHZ061 /tmp/fc.html #without the -m 1 we get the latest 3 weather reports.
wget -q "http://www.nws.noaa.gov/view/prodsByState.php?state=OH&prodtype=zone" -O /tmp/fc.html && awk '/OHZ061/{found=1} found{print; if(/\$\$/) exit}' /tmp/fc.html # it appears that this text forecast has been deprecated for Ohio :( ; it appears the new "text-only" format is in html http://forecast.weather.gov/MapClick.php?zoneid=OHZ061&TextType=1 

#http://forecast.weather.gov/MapClick.php?zoneid=OHZ055&TextType=1

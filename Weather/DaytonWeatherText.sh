#!/bin/bash

bash ./WeatherText.sh Dayton

# #good set of text weather resources: http://www.nws.noaa.gov/view/states.php?state=OH
# wget -q "http://www.nws.noaa.gov/view/prodsByState.php?state=OH&prodtype=hourly" -O /tmp/currentconditions.html && grep -A 10 -m 1 SOUTHWEST /tmp/currentconditions.html | sed -n -e '3p' -e '7p' -e '8p' -e '9p'
# #sed -n -e '3p' -e '7p' -e '8p' -e '9p' ==> only print the 3rd,7th,8th and 9th line
# echo "--------============----------"

# #this is a little overkill since it gets info for the whole state and that ends up being a ~1MB file. The connection is BW limited I bet at ~30kb/s so it takes about 30s to get the file. <---this was MUCH faster when I plugged the ethernet cord straight into the pc instead of going from wireless router/mdem to my netgear router. #nice full text forecast for entire state.

# #wget -q "http://www.nws.noaa.gov/view/prodsByState.php?state=OH&prodtype=zone" -O /tmp/fc.html && grep -A 28 -m 1 OHZ061 /tmp/fc.html #without the -m 1 we get the latest 3 weather reports.
# wget -q "http://www.nws.noaa.gov/view/prodsByState.php?state=OH&prodtype=zone" -O /tmp/fc.html && awk '/OHZ061/{found=1} found{print; if(/\$\$/) exit}' /tmp/fc.html 

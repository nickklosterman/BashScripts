#!/bin/bash

feh http://radar.weather.gov/lite/N0R/ILN_0.png "http://aviationweather.gov/data/obs/sat/goes/vis_goesE.jpg" "http://aviationweather.gov/data/obs/sat/goes/vis_goesW.jpg" http://www.goes.noaa.gov/GIFS/ECI8.JPG http://www.goes.noaa.gov/GIFS/ECI7.JPG http://www.goes.noaa.gov/GIFS/ECI6.JPG http://www.goes.noaa.gov/GIFS/ECI5.JPG &

#feh http://radar.weather.gov/lite/N0R/ILN_0.png http://www.goes.noaa.gov/GIFS/ECI8.JPG http://www.goes.noaa.gov/GIFS/ECI7.JPG http://www.goes.noaa.gov/GIFS/ECI6.JPG http://www.goes.noaa.gov/GIFS/ECI5.JPG &
#wget "http://forecast.weather.gov/MapClick.php?lat=39.722504198231405&lon=-84.1549301147461&site=iln&unit=0&lg=en&FcstType=text" -O /tmp/forecast.html
#grep -A 2 "Detailed text forecast" /tmp/forecast.html
#use python and xml parser for forecast
# xml: http://forecast.weather.gov/MapClick.php?lat=39.74672&lon=-84.19373&FcstType=dwml

#good set of text weather resources: http://www.nws.noaa.gov/view/states.php?state=OH
#wget "http://www.nws.noaa.gov/view/prodsByState.php?state=OH&prodtype=hourly" -O /tmp/currentconditions.html && grep -A 10 -m 1 SOUTHWEST /tmp/currentconditions.html

#this is a little overkill since it gets info for the whole state and that ends up being a ~1MB file. The connection is BW limited I bet at ~30kb/s so it takes about 30s to get the file. #nice full text forecast for entire state.
#wget "http://www.nws.noaa.gov/view/prodsByState.php?state=OH&prodtype=zone" -O /tmp/fc.html && grep -A 28 -m 1 OHZ061 /tmp/fc.html #without the -m 1 we get the latest 3 weather reports.

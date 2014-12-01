#!/bin/bash
NumberOfExpectedArguments=2
if [ $# -lt $NumberOfExpectedArguments ]
then 
    echo "Please specify the three letter radar station identifier and the radar image 0-7, 0 being the most recent radar image"
    echo "GetRadarImage.sh ILN 0"
else
    radarStation=$1
    imagenumber=$2
#radar images are only 0-7
    if [ $imagenumber -gt 7 ]
    then
	imagenumber=7
    fi
    wget -q -O /tmp/${radarStation}Radar http://radar.weather.gov/ridge/lite/NCR/${radarStation}_${imagenumber}.png
fi

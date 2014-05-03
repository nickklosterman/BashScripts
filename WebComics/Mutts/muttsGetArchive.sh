#!/bin/bash
#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
NumberOfExpectedArguments=0
NumberOfImages=66 # the mutts website states that only the last 5 weeks of strips are archived due to syndication licensing.

if [ $# -ne $NumberOfExpectedArguments ]
then
    echo "Please specify the number of comics to grab"
else 
    TodaysDate=`date +%F`
    StartFromBack=`date --date "$TodaysDate $NumberOfImages days ago" +%F`
    counter=$NumberOfImages
    filelist=""
    while [ $counter -ge 0 ]; do
#	StartFromBack=`date --date "$TodaysDate $counter days ago" +%F`
	StartFromBackDay=`date --date "$TodaysDate $counter days ago" +%d`
	StartFromBackMonth=`date --date "$TodaysDate $counter days ago" +%m`
	StartFromBackLastTwoDigitsOfYear=`date --date "$TodaysDate $counter days ago" +%g`
	filename=$StartFromBackMonth$StartFromBackDay$StartFromBackLastTwoDigitsOfYear.gif
	echo $filename
                  #https://muttscomics.com/sites/default/files/strips/050314.gif
	filelist+="https://muttscomics.com/sites/default/files/strips/$filename "
	#filelist+="http://www.muttscomics.com/art/images/daily/$filename "
	let "counter-=1"
    done
#    echo "${filelist}"
#attempted to use -p for preload but it isn't working
    wget -U "Mozilla"  -nc  $filelist --no-check-certificate &
    feh --geometry 1024x768 -S name .

fi



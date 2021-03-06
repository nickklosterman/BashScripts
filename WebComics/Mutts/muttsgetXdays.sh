#!/bin/bash
#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
NumberOfExpectedArguments=1
NumberOfImages=$(( $1-1 ))

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
#	echo $filename
	filelist+="http://www.muttscomics.com/art/images/daily/$filename "
	let "counter-=1"
    done
    echo "${filelist}"
#attempted to use -p for preload but it isn't working
    feh $filelist
fi



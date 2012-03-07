#!/bin/bash
#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
NumberOfExpectedArguments=1
NumberOfImages=$(( $1-1 ))

if [ $# -ne $NumberOfExpectedArguments ]
then
    echo "Please specify the number of sinfest comics to grab"
else 
    TodaysDate=`date +%F`
    StartFromBack=`date --date "$TodaysDate $NumberOfImages days ago" +%F`
    counter=$NumberOfImages
    filelist=""
    while [ $counter -ge 0 ]; do
	StartFromBack=`date --date "$TodaysDate $counter days ago" +%F`
	filename=$StartFromBack.gif
#	echo $filename
	filelist+="http://www.sinfest.net/comikaze/comics/$filename "
	let "counter-=1"
    done
    echo "${filelist}"
#attempted to use -p for preload but it isn't working
    feh $filelist
fi



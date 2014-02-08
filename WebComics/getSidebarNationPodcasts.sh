#!/bin/bash
#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
NumberOfExpectedArguments=2
NumberOfItemsStart=$(( $1 ))
NumberOfItemsStop=$(( $2 ))

if [ $# -ne $NumberOfExpectedArguments ]
then
    echo "Please specify the podcast episode number to start downloading from"
else 
    counter=$NumberOfItemsStart
    while [ $counter -gt $NumberOfItemsStop ]; do
	if [ ! -f SiDEBAR_Ep_$counter.mp3 ]
	then
	    #wget --limit-rate=65k "http://traffic.libsyn.com/sidebar/SiDEBAR_Ep_$counter.mp3"
	    wget --limit-rate=165k "http://traffic.libsyn.com/sidebar/SiDEBAR_Ep_$counter.mp3"
	    else
	    echo "Skipping SiDEBAR_Ep_$counter.mp3"
	fi
	let "counter-=1"
    done

fi



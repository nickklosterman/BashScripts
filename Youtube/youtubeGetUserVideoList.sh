#!/bin/bash

function getYoutubeUsersVideos() {
    echo ${1}
    inputfilename="/tmp/youtube${1}"
    outputfilename="youtube_${1}_videolist.txt"
    echo ${inputfilename}
    echo ${outputfilename}
    wget -U Mozilla http://www.youtube.com/user/"${1}"/videos -O "${inputfilename}"
    #http://www.youtube.com/user/deathwiater/videos
    #grep 'href="/watch' /tmp/sycrayoutube | sed 's/.*href="\/watch?v=//;s/".*//;' | uniq  #get just the video guid
    #grep 'href="/watch' /tmp/sycrayoutube | sed 's/.*href="//;s/".*//;' | uniq
    grep 'href="/watch' "${inputfilename}" | sed 's/.*href="/http:\/\/www.youtube.com/;s/".*//;' | uniq > "${outputfilename}"
}

if [ -f "$1" ]
then 
    while read LINE 
    do 
	getYoutubeUsersVideos "${LINE}"
    done < "${1}"
else 
    until [ -z "$1" ] 
    do 
	getYoutubeUsersVideos "${1}"
	shift 
    done 

fi 

#!/bin/bash

options="--write-description --write-info-json --write-annotations --write-thumbnail --no-playlist"

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
   videoUrl=$( grep 'href="/watch' "${inputfilename}" | sed 's/.*href="/http:\/\/www.youtube.com/;s/".*//;' | uniq ) #| youtube-dl
   youtube-dl ${options} ${videoUrl} 
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
	if [ ! -d "${1}" ]
	then 
	    mkdir "${1}"
	fi
	cd "${1}"
	getYoutubeUsersVideos "${1}"
	cd ..
	shift 
    done 

fi 

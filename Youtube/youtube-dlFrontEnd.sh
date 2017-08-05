#!/bin/bash

 # --write-description              write video description to a .description file
 #    --write-info-json                write video metadata to a .info.json file
 #    --write-annotations              write video annotations to a .annotation file
 #    --write-thumbnail 

options="--write-description --write-info-json --write-annotations --write-thumbnail --no-playlist -f 'bestvideo[height<=1080]+bestaudio"
if [ $# -lt 1 ]
then
    echo "${0} directions;"
else
    if [ -f "$1" ] #if we specified a file on the command line then read the file and spit it out else parse args as stock tickers
    then
	echo "Executing on a file"
	while read LINE
	do
	    echo " operating on ${LINE}"
	    youtube-dl ${options} "${LINE}"
	done < "$1"
    else 
	until [ -z "$1" ] #parse args as stock tickers
	do
	    #CLI method won't work with URLs grabbed from "lists" as the & specifying the list parameter breaks teh CLI as it is interpreted as a backgrounding action. 
	    #	    echo "youtube-dl '${1}'"
	    echo " operating on ${1}"
	    youtube-dl ${options} "${1}"
	    shift
	done 
    fi
fi





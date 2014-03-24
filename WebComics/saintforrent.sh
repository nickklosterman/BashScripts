#!/bin/bash

#http://www.saintforrent.com/comics/1395380411-011.gif

fileExtension=gif

#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
function performCleanup () {
    echo "Remove temporary files (y/n)?"
    read inputkey
    if [ "$inputkey" == "y" ] || [ "$inputkey" == "Y" ]
    then 
	echo "Removing temporary files"
	rm /tmp/saintforrent*
    else 
	echo "Not removing temporary files"
    fi
}

function performExecOnFile () {
    while read LINE
    do
	echo $LINE
	exec $LINE & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}


function performWgetOnFile () {
    while read LINE
    do
	#	    echo $LINE
	wget $LINE -nv -U "IE9" -O - >> /tmp/saintforrent & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}

function performWgetOnFileForImages () {
    while read LINE
    do
	#	    echo $LINE
	wget "${LINE}" -nv -nc -U "IE9"
	#sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}



function fileCheck () {
START=1
STOP="${1}"
    for (( cnter=START; cnter<=STOP; cnter++))
    do
	filename=$(printf "%03d" ${cnter} );
	if [ ! -e ${filename}.${fileExtension} ] #|| [ ! -e ${cnter}.${fileExtension} ]
	then
	    echo ${filename} ${cnter} ${fileExtension}
	fi
    done

}


function fileRenameToPng () {
echo "See the jpg rename method"
read somekey
START=1
STOP="${1}"
    for (( cnter=START; cnter<=STOP; cnter++))
    do
	filename=$(printf "%03d" ${cnter} );
	if [ ! -e ${filename}.${fileExtension} ] || [ ! -e ${cnter}.${fileExtension} ] && [ -e ${filename}.png ]
	then
	    mv ${filename}.png  ${filename}.${fileExtension}
	fi
    done

}


function zeroPadNumericFileNames () {
    for cntr in {1..99}
    do 
	filename=$(printf "%03d" ${cntr} );
	echo $filename 
	if [ ! -e ${filename}.${fileExtension} ]
	then 
	    mv ${cntr}.${fileExtension} ${filename}.${fileExtension}
	    #to easily get rid of files run the commands below
	    #rm [1-9][0-9].${fileExtension}
	    #rm [1-9].${fileExtension}
	else
	    echo "not moving ${cntr}.${fileExtension} to ${filename}.${fileExtension} bc it all ready exists"  
	fi
    done
}

function getHTMLPages () {
    echo "getHTMLPages"
    counter=${1}
    while [ $counter -gt 0 ]; do
 
    	fileName=$(printf "%03d" ${counter})
#http://www.saintforrent.com/comics/1395380411-011.gif
#http://www.saintforrent.com/index.php?id=161
    	echo "http://www.saintforrent.com/index.php?id=${counter}/ " >> /tmp/saintforrentpages
    	#echo ${counter}
    	let "counter-=1"
    done

#    performWgetOnFileForImages /tmp/saintforrentpages
    performWgetOnFile /tmp/saintforrentpages
}

function getPagesInFile() {
    echo "getPagesInFile"
    numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
    cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/saintforrent
}



function fileRenameToJpg () {

    for item in *.png
    do
	fileName=${item%%.*}
	mv "${item}".png  "${filename}".${fileExtension}

    done
}


function renameStripGUIDFromFilename () {

    for item in *.jpg *.png *.gif
    do
#	fileName=${item%%.*}
	fileName=${item}
	shopt -s extglob    # Turn on extended pattern support
#	fileName2=$( echo "${fileName}" | sed 's/[^-]*//;s/^-//' ) # grabs up to first dash but doesn't get rid of dash, so add'l command to remove it
	fileName2=$( echo "${fileName}" | sed 's/[^-]*/rename/;' ) # grabs up to first dash but doesn't get rid of dash
#	fileName2=$( echo "${fileName}" | sed 's/.*-//' ) #grabs all the way to last -
#	fileName2=$( echo "${fileName}" | sed 's/^(.*?)-//' ) 

	extension=${i##*.}
#	echo ${fileName2}

	cp "${item}" ${fileName2}
#	mv "${item}".png  "${filename}".${fileExtension}

    done
}


##########
##########
##-Main-##
##########
##########

NumberOfExpectedArguments=1
NumberOfImages=${1}
debugswitch=1 #setting to something besides 1 will turn off bits of code
if [ 1 -eq $debugswitch ]
then 
    if [ $# -ne $NumberOfExpectedArguments ]
    then
	echo "Please specify the number of comics to grab"
    else 
	performCleanup
	
#	getHTMLPages $NumberOfImages

	sleep 2s

#v id="comicbody"><img src="comics/../comics/1395380411-011.gif" id="comic" border="0" /><br /></div><div class="nav"><a href="/index.php?id=160" class="prev" rel="prev">&lt;PREV</a><
#http://www.saintforrent.com/comics/1395380411-011.gif
	grep 'id="comic"' /tmp/saintforrent | sed 's/.*img src="comics\/../ http:\/\/www.saintforrent.com/;s/".*//;' | sort | uniq  > /tmp/saintforrentcomicimages


	performWgetOnFileForImages /tmp/saintforrentcomicimages

#	fileRenameToJpg
	renameStripGUIDFromFilename

	# wait for /tmp/saintforrent to be populated
	sleep 5s	

	zip Saintforrent rename*.${fileExtension} 
	mv Saintforrent.zip Saintforrent.cbz
	evince Saintforrent.cbz  &
    fi 
fi



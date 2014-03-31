#!/bin/bash
#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward

#this version goes through page by page and gets teh image and names it before going on to the next page. this tidies things up since the file nameing isn't sequential


fileExtension=jpg
imagefilecounter=1

function performCleanup () {
    echo "Remove temporary files (y/n)?"
    read inputkey
    if [ "$inputkey" == "y" ] || [ "$inputkey" == "Y" ]
    then 
	echo "Removing temporary files"
	rm /tmp/nimona*
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
	wget $LINE -nv -O - >> /tmp/nimona & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}

function performWgetOnFileGeneric () {
    while read LINE
    do
	wget $LINE -nv -O - >> "${2}" & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}

function performWgetOnImages () {
    while read LINE
    do
	wget $LINE -nv -U "Mozilla" -nc  & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}



function fileCheck () {
    for cnter in {1..481}
    do
	filename=$(printf "%03d" ${cnter} )
	if [ ! -e ${filename}.jpg ] || [ ! -e ${cnter}.jpg ]
	then
	    echo ${filename} ${cnter}
	fi
    done

}

function zeroPadNumericFileNames () {
    for cntr in {1..99}
    do 
	filename=$(printf "%03d" ${cntr} );
	echo $filename 
	if [ ! -e ${filename}.jpg ]
	then 
	    mv ${cntr}.jpg ${filename}.jpg
	    #to easily get rid of files run the commands below
	    #rm [1-9][0-9].jpg
	    #rm [1-9].jpg
	else
	    echo "not moving ${cntr}.jpg to ${filename}.jpg bc it all ready exists"  
	fi
    done
}


function getNextPageUrl() {
echo "stuff"
}

function getImage() {
echo "stuff"
}

function getArchivePages() {
    echo "getArchivePages"
    wget http://gingerhaze.com/nimona/archive -O /tmp/nimonaarchive
    lastpage=$(grep "Go to last page" /tmp/nimonaarchive | sed 's/.*page=//;s/".*//')

    echo "http://gingerhaze.com/nimona/archive" > /tmp/nimonaarchive

    echo "lastpage ${lastpage}"
    counter=${lastpage}
    while [ $counter -gt 0 ]; do
	echo "http://gingerhaze.com/nimona/archive?page=${counter}/ "  >> /tmp/nimonaarchive
	let "counter-=1"
    done
    performWgetOnFileGeneric /tmp/nimonaarchive /tmp/nimonasinglepagelinks

}

function SortUniqFile() {
    sort "${1}" | uniq > /tmp/89724587439.txt
    mv /tmp/89724587439.txt "${1}"
}

function getIndividualPages() {
    grep '<a href="/nimona/comic/' /tmp/nimonasinglepagelinks | sed 's/.*a href="\/nimona\/comic\//http:\/\/www.gingerhaze.com\/nimona\/comic\//;s/".*//' >> /tmp/nimonasinglepagelinksabsolute
#    grep 'foaf:Image' /tmp/nimonasinglepagelinks | sed 's/.*a href="\/nimona\/comic\//http:\/\/www.gingerhaze.com\/nimona\/comic\//;s/".*//' >> /tmp/nimonasinglepagelinksabsolute

    performWgetOnFileGeneric  /tmp/nimonasinglepagelinksabsolute  /tmp/nimonaallinone
}

function getIndividualImages()  {
#    grep foaf:Image /tmp/nimonaallinone | sed 's/.*src="//;s/".*//' >> /tmp/nimonaimages
    grep foaf:Image /tmp/nimonaallinone | sed 's/.*foaf:Image" src="//;s/".*//' >> /tmp/nimonaimages
    SortUniqFile /tmp/nimonaimages 

    performWgetOnImages /tmp/nimonaimages
}

function getImageFromPage()  {
    image=$(  grep foaf:Image ${1} | sed 's/.*foaf:Image" src="//;s/".*//' )
    fileNumber=$( printf "%03d" ${imagefilecounter} )
    echo "nimona_${fileNumber}.$fileExtension"
    wget ${image} -nv -nc -O nimona_${fileNumber}.$fileExtension &
    let "imagefilecounter+=1"
}

function getHTMLPages () {
    echo "getHTMLPages"
    counter=${1}
    while [ $counter -gt 0 ]; do
	echo "http://nimona.enenkay.com/comic/${counter}/ " >> /tmp/nimonapages
	#echo ${counter}
	let "counter-=1"
    done

    performWgetOnFile /tmp/nimonapages
}

function getPagesInFile() {
    echo "getPagesInFile"
    numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
    cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/nimona
}

function getNextUrlFromPage() {
#<li><a href="/nimona/comic/page-2"><img src="http://gingerhaze.com/sites/default/files/comicdrop/comicdrop_next_label_file.png"></a></li>
nextURL=$( grep comicdrop_next_label "${1}" | uniq | sed 's/.*a href="/http:\/\/www.gingerhaze.com/;s/".*//' )
echo ${nextURL} >> nimonalog.txt
echo ${nextURL}
wget ${nextUrl} -O /tmp/nimonasinglepage
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
	
	wget http://gingerhaze.com/nimona/comic/page-1 -O /tmp/nimonasinglepage
	oldNextUrl=""
	nextUrl="--"
	while [ "${nextUrl}" != "${oldNextUrl}" ]  # you need the quotes for it to work
	do
	    oldNextUrl=${nextUrl}	    
	    getImageFromPage /tmp/nimonasinglepage
	    nextUrl=$( getNextUrlFromPage /tmp/nimonasinglepage )
	    getNextUrlFromPage /tmp/nimonasinglepage 
	    echo "new: ${nexUrl} old: ${oldNextUrl}"
	done
	    echo "new: -${nexUrl}- old: ${oldNextUrl}"
	# #	getArchivePages
# #	getIndividualPages
# 	SortUniqFile /tmp/nimonaallinone
# 	getIndividualImages
	sleep 4s

	# getHTMLPages $NumberOfImages

	# # wait for /tmp/nimona to be populated
	# sleep 5s	

	# grep "<img src=" /tmp/nimona |  sed 's/.*<img src="\/img\/comic\//wget -nc  http:\/\/nimona.enenkay.com\/img\/comic\//;s/".*//' | sort | uniq  > /tmp/nimonacomicimages

	# performExecOnFile /tmp/nimonacomicimages

	# #wait for all downloads to complete. vary this depending on the size of the images and download speeds.
	# sleep 10s


	zip Nimona *.${fileExtension}
	mv Nimona.zip Nimona.cbz
	evince Nimona.cbz  &
    fi 
fi



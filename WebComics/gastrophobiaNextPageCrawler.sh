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
	rm /tmp/gastrophobia*
    else 
	echo "Not removing temporary files"
    fi
}

# function performExecOnFile () {
#     while read LINE
#     do
# 	echo $LINE
# 	exec $LINE & #without this backgroudn we only get one image.
# 	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
#     done < ${1}
# }


# function performWgetOnFile () {
#     while read LINE
#     do
# 	#	    echo $LINE
# 	wget $LINE -nv -O - >> /tmp/gastrophobia & #without this backgroudn we only get one image.
# 	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
#     done < ${1}
# }

# function performWgetOnFileGeneric () {
#     while read LINE
#     do
# 	wget $LINE -nv -O - >> "${2}" & #without this backgroudn we only get one image.
# 	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
#     done < ${1}
# }

# function performWgetOnImages () {
#     while read LINE
#     do
# 	wget $LINE -nv -U "Mozilla" -nc  & #without this backgroudn we only get one image.
# 	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
#     done < ${1}
# }



# function fileCheck () {
#     for cnter in {1..481}
#     do
# 	filename=$(printf "%03d" ${cnter} )
# 	if [ ! -e ${filename}.jpg ] || [ ! -e ${cnter}.jpg ]
# 	then
# 	    echo ${filename} ${cnter}
# 	fi
#     done

# }

# function zeroPadNumericFileNames () {
#     for cntr in {1..99}
#     do 
# 	filename=$(printf "%03d" ${cntr} );
# 	echo $filename 
# 	if [ ! -e ${filename}.jpg ]
# 	then 
# 	    mv ${cntr}.jpg ${filename}.jpg
# 	    #to easily get rid of files run the commands below
# 	    #rm [1-9][0-9].jpg
# 	    #rm [1-9].jpg
# 	else
# 	    echo "not moving ${cntr}.jpg to ${filename}.jpg bc it all ready exists"  
# 	fi
#     done
# }

# function getArchivePages() {
#     echo "getArchivePages"
#     wget http://gingerhaze.com/gastrophobia/archive -O /tmp/gastrophobiaarchive
#     lastpage=$(grep "Go to last page" /tmp/gastrophobiaarchive | sed 's/.*page=//;s/".*//')

#     echo "http://gingerhaze.com/gastrophobia/archive" > /tmp/gastrophobiaarchive

#     echo "lastpage ${lastpage}"
#     counter=${lastpage}
#     while [ $counter -gt 0 ]; do
# 	echo "http://gingerhaze.com/gastrophobia/archive?page=${counter}/ "  >> /tmp/gastrophobiaarchive
# 	let "counter-=1"
#     done
#     performWgetOnFileGeneric /tmp/gastrophobiaarchive /tmp/gastrophobiasinglepagelinks

# }

# function SortUniqFile() {
#     sort "${1}" | uniq > /tmp/89724587439.txt
#     mv /tmp/89724587439.txt "${1}"
# }

# function getIndividualPages() {
#     grep '<a href="/gastrophobia/comic/' /tmp/gastrophobiasinglepagelinks | sed 's/.*a href="\/gastrophobia\/comic\//http:\/\/www.gingerhaze.com\/gastrophobia\/comic\//;s/".*//' >> /tmp/gastrophobiasinglepagelinksabsolute
#     performWgetOnFileGeneric  /tmp/gastrophobiasinglepagelinksabsolute  /tmp/gastrophobiaallinone
# }

# function getIndividualImages()  {
#     grep foaf:Image /tmp/gastrophobiaallinone | sed 's/.*foaf:Image" src="//;s/".*//' >> /tmp/gastrophobiaimages
#     SortUniqFile /tmp/gastrophobiaimages 
#     performWgetOnImages /tmp/gastrophobiaimages
# }
# function getHTMLPages () {
#     echo "getHTMLPages"
#     counter=${1}
#     while [ $counter -gt 0 ]; do
# 	echo "http://gastrophobia.enenkay.com/comic/${counter}/ " >> /tmp/gastrophobiapages
# 	#echo ${counter}
# 	let "counter-=1"
#     done

#     performWgetOnFile /tmp/gastrophobiapages
# }

# function getPagesInFile() {
#     echo "getPagesInFile"
#     numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
#     cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/gastrophobia
# }

function getImageFromPage()  {
    image=$(  grep 'id="comic"' ${1} | sed 's/.*img src="/http:\/\/www.gastrophobia.com\//;s/".*//' )

#if it is a page where there is a video or something we still stick in a placeholder 
    if [ "${image}" = "" ]
    then 
	convert -background white -fill black -pointsize 72 label:"no image"  gastrophobia_${fileNumber}.${fileExtension}
    else
	fileNumber=$( printf "%03d" ${imagefilecounter} )
	echo "${image}"
	echo "${image}" >> /tmp/gastrophobiaImages.txt
	echo "gastrophobia_${fileNumber}.$fileExtension"
	wget ${image} -nv -nc -U "IE9" -O gastrophobia_${fileNumber}.${fileExtension} &
    fi
    let "imagefilecounter+=1"
}


function getNextUrlFromPage() {
#Step 2 here:
#the rel=next link is all on one line, so we are just going to key off the comicbody id and the comic image is linked to the next page so we'll use that. 
nextURL=$( grep ' id="comic"' "${1}" | sed 's/.*a href="\/index.php?id=/http:\/\/www.gastrophobia.com\/index.php?id=/;s/".*//' )
echo ${nextURL} >> /tmp/gastrophobialog.txt
echo "--${nextURL}--"
if [ "${nextURL}" != "" ]
then
    wget "${nextURL}" -O /tmp/gastrophobiasinglepage
fi
}

function getUrlOfLastPage() {
wget http://www.gastrophobia.com/index.php -O /tmp/gastrophobiasinglepage
lastpage=$( grep 'class="last"' /tmp/gastrophobiasinglepage | sed 's/.*rel="next"//;s/.*id=//;s/".*//' )
echo ${lastpage}
}


##########
##########
##-Main-##
##########
##########

NumberOfExpectedArguments=0
NumberOfImages=${1}
debugswitch=1 #setting to something besides 1 will turn off bits of code
if [ 1 -eq $debugswitch ]
then 
    if [ $# -ne $NumberOfExpectedArguments ]
    then
	echo "Please specify the number of comics to grab"
    else 
	counter=14 #this is the id of the first page
	performCleanup
	lastpage=$( getUrlOfLastPage )
	
	#Step 1 here: this is the start page to begin scraping from
	
	oldNextUrl="blank"
	nextUrl="empty"
	while [ ${counter} -lt ${lastpage} ]  # you need the quotes for it to work
	do
	    wget http://www.gastrophobia.com/index.php?date=2014-03-26 } -U "Mozilla" -O /tmp/gastrophobiasinglepage
	    getImageFromPage /tmp/gastrophobiasinglepage
	    let 'counter+=1'
	done
	sleep 3s

	zip Gastrophobia gastrophobia*.${fileExtension}
	mv Gastrophobia.zip Gastrophobia.cbz
	evince Gastrophobia.cbz  &
	rm gastrophobia*.${fileExtension}
    fi 
fi
echo ""


# Step 1) get the url of the first page
# Step 2) determine a parse method for the 'next' page
# Step 3) determine a parse method for each page's image

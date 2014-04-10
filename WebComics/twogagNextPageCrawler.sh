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
	rm /tmp/twogag*
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
# 	wget $LINE -nv -O - >> /tmp/twogag & #without this backgroudn we only get one image.
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
#     wget http://gingerhaze.com/twogag/archive -O /tmp/twogagarchive
#     lastpage=$(grep "Go to last page" /tmp/twogagarchive | sed 's/.*page=//;s/".*//')

#     echo "http://gingerhaze.com/twogag/archive" > /tmp/twogagarchive

#     echo "lastpage ${lastpage}"
#     counter=${lastpage}
#     while [ $counter -gt 0 ]; do
# 	echo "http://gingerhaze.com/twogag/archive?page=${counter}/ "  >> /tmp/twogagarchive
# 	let "counter-=1"
#     done
#     performWgetOnFileGeneric /tmp/twogagarchive /tmp/twogagsinglepagelinks

# }

# function SortUniqFile() {
#     sort "${1}" | uniq > /tmp/89724587439.txt
#     mv /tmp/89724587439.txt "${1}"
# }

# function getIndividualPages() {
#     grep '<a href="/twogag/comic/' /tmp/twogagsinglepagelinks | sed 's/.*a href="\/twogag\/comic\//http:\/\/www.gingerhaze.com\/twogag\/comic\//;s/".*//' >> /tmp/twogagsinglepagelinksabsolute
#     performWgetOnFileGeneric  /tmp/twogagsinglepagelinksabsolute  /tmp/twogagallinone
# }

# function getIndividualImages()  {
#     grep foaf:Image /tmp/twogagallinone | sed 's/.*foaf:Image" src="//;s/".*//' >> /tmp/twogagimages
#     SortUniqFile /tmp/twogagimages 
#     performWgetOnImages /tmp/twogagimages
# }
# function getHTMLPages () {
#     echo "getHTMLPages"
#     counter=${1}
#     while [ $counter -gt 0 ]; do
# 	echo "http://twogag.enenkay.com/comic/${counter}/ " >> /tmp/twogagpages
# 	#echo ${counter}
# 	let "counter-=1"
#     done

#     performWgetOnFile /tmp/twogagpages
# }

# function getPagesInFile() {
#     echo "getPagesInFile"
#     numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
#     cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/twogag
# }

function getImageFromPage()  {
    image=$(  grep 'id="comic"' -A 3 ${1} | grep "src" | sed 's/.*src="//;s/".*//' )
    fileNumber=$( printf "%03d" ${imagefilecounter} )
    echo "${image}"
    echo "${image}" >> /tmp/twogagImages.txt
    echo "twogag_${fileNumber}.$fileExtension"
    wget ${image} -nv -nc -U "IE9" -O twogag_${fileNumber}.$fileExtension &
    let "imagefilecounter+=1"
}


function getNextUrlFromPage() {
#Step 2 here:
nextURL=$( grep "rel='next'" "${1}" | uniq | sed "s/.*href='//;s/'.*//" )
echo ${nextURL} >> /tmp/twogaglog.txt
echo "--${nextURL}--"
if [ "${nextURL}" != "" ]
then
    wget "${nextURL}" -O /tmp/twogagsinglepage
fi
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
	
	#Step 1 here: this is the start page to begin scraping from
	wget http://www.twogag.com/archives/4 -U "Mozilla" -O /tmp/twogagsinglepage
	oldNextUrl="blank"
	nextUrl="empty"
	while [ "${nextUrl}" != "${oldNextUrl}" ] && [ "${nextUrl}" != "" ]  # you need the quotes for it to work
	do
	    oldNextUrl=${nextUrl}	    
	    getImageFromPage /tmp/twogagsinglepage
	    nextUrl=$( getNextUrlFromPage /tmp/twogagsinglepage )
	    echo "new: ${nexUrl} old: ${oldNextUrl}"
	done
	    echo "new: -${nexUrl}- old: ${oldNextUrl}"

	sleep 3s

	zip Twogag twogag*.${fileExtension}
	mv Twogag.zip Twogag.cbz
	evince Twogag.cbz  &
    fi 
fi
echo ""


# Step 1) get the url of the first page
# Step 2) determine a parse method for the 'next' page
# Step 3) determine a parse method for each page's image

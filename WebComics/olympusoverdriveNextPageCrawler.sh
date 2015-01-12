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
	rm /tmp/olympusoverdrive*
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
# 	wget $LINE -nv -O - >> /tmp/olympusoverdrive & #without this backgroudn we only get one image.
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
#     wget http://gingerhaze.com/olympusoverdrive/archive -O /tmp/olympusoverdrivearchive
#     lastpage=$(grep "Go to last page" /tmp/olympusoverdrivearchive | sed 's/.*page=//;s/".*//')

#     echo "http://gingerhaze.com/olympusoverdrive/archive" > /tmp/olympusoverdrivearchive

#     echo "lastpage ${lastpage}"
#     counter=${lastpage}
#     while [ $counter -gt 0 ]; do
# 	echo "http://gingerhaze.com/olympusoverdrive/archive?page=${counter}/ "  >> /tmp/olympusoverdrivearchive
# 	let "counter-=1"
#     done
#     performWgetOnFileGeneric /tmp/olympusoverdrivearchive /tmp/olympusoverdrivesinglepagelinks

# }

# function SortUniqFile() {
#     sort "${1}" | uniq > /tmp/89724587439.txt
#     mv /tmp/89724587439.txt "${1}"
# }

# function getIndividualPages() {
#     grep '<a href="/olympusoverdrive/comic/' /tmp/olympusoverdrivesinglepagelinks | sed 's/.*a href="\/olympusoverdrive\/comic\//http:\/\/www.gingerhaze.com\/olympusoverdrive\/comic\//;s/".*//' >> /tmp/olympusoverdrivesinglepagelinksabsolute
#     performWgetOnFileGeneric  /tmp/olympusoverdrivesinglepagelinksabsolute  /tmp/olympusoverdriveallinone
# }

# function getIndividualImages()  {
#     grep foaf:Image /tmp/olympusoverdriveallinone | sed 's/.*foaf:Image" src="//;s/".*//' >> /tmp/olympusoverdriveimages
#     SortUniqFile /tmp/olympusoverdriveimages 
#     performWgetOnImages /tmp/olympusoverdriveimages
# }
# function getHTMLPages () {
#     echo "getHTMLPages"
#     counter=${1}
#     while [ $counter -gt 0 ]; do
# 	echo "http://olympusoverdrive.enenkay.com/comic/${counter}/ " >> /tmp/olympusoverdrivepages
# 	#echo ${counter}
# 	let "counter-=1"
#     done

#     performWgetOnFile /tmp/olympusoverdrivepages
# }

# function getPagesInFile() {
#     echo "getPagesInFile"
#     numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
#     cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/olympusoverdrive
# }

function getImageFromPage()  {
    image=$(  grep 'id="comic"' ${1} | sed 's/.*img src="/http:\/\/www.olympusoverdrive.com\//;s/".*//' )
    fileNumber=$( printf "%03d" ${imagefilecounter} )
    echo "${image}"
    echo "${image}" >> /tmp/olympusoverdriveImages.txt
    echo "olympusoverdrive_${fileNumber}.$fileExtension"
    wget ${image} -nv -nc -U "IE9" -O olympusoverdrive_${fileNumber}.$fileExtension &
    let "imagefilecounter+=1"
}


function getNextUrlFromPage() {
#Step 2 here:
#the rel=next link is all on one line, so we are just going to key off the comicbody id and the comic image is linked to the next page so we'll use that. 
nextURL=$( grep ' id="comic"' "${1}" | sed 's/.*a href="\/index.php?id=/http:\/\/www.olympusoverdrive.com\/index.php?id=/;s/".*//' )
echo ${nextURL} >> /tmp/olympusoverdrivelog.txt
echo "--${nextURL}--"
if [ "${nextURL}" != "" ]
then
    wget "${nextURL}" -O /tmp/olympusoverdrivesinglepage
fi
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
	performCleanup
	
	#Step 1 here: this is the start page to begin scraping from
	wget http://www.olympusoverdrive.com/index.php?id=14 -U "Mozilla" -O /tmp/olympusoverdrivesinglepage
	oldNextUrl="blank"
	nextUrl="empty"
	while [ "${nextUrl}" != "${oldNextUrl}" ] && [ "${nextUrl}" != "" ]  # you need the quotes for it to work
	do
	    oldNextUrl=${nextUrl}	    
	    getImageFromPage /tmp/olympusoverdrivesinglepage
	    nextUrl=$( getNextUrlFromPage /tmp/olympusoverdrivesinglepage )
	    echo "new: ${nexUrl} old: ${oldNextUrl}"
	done
	    echo "new: -${nexUrl}- old: ${oldNextUrl}"

	sleep 3s

	zip Olympusoverdrive olympusoverdrive*.${fileExtension}
	mv Olympusoverdrive.zip Olympusoverdrive.cbz
	evince Olympusoverdrive.cbz  &
    fi 
fi
echo ""


# Step 1) get the url of the first page
# Step 2) determine a parse method for the 'next' page
# Step 3) determine a parse method for each page's image

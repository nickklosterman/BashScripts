#!/bin/bash

#I think this version is simplified from the previous version. Before I had a separate function for the mature stuff but here I use the thumbnail address (which I was keying off for the mature content) for all the images. 
#NOTE::you can't be logged in and view the source and go off that bc diff pages are served to you when you are logged in vs this script which isn't logged in
#2011.06.23 It appears that DA wised up and now you can't just chop the 150 from the url to get the mature version. Only the thumbnail is accessible without brutefocring the URL. Which we'll be doing.
GetFullSizeImages=0
GetLargeImages=0


function downloadIndividualPages ()
{
#http://www.faqs.org/docs/abs/HTML/assortedtips.html look at the passing and returning arrays section.
    passed_array=( `echo "$1"` )
    for x in ${passed_array[@]} #1
    do 
	echo "Downloading $x"
	wget -nc -U Mozilla "$x"
    done
}

function removeIndividualPages ()
{
    passed_array=( `echo "$1"` )
    for x in ${passed_array[@]}
    do 
	echo "Removing  $x"
	rm "$x"
    done
}

function downloadFullImageFromFile ()
{
    passed_array=( `echo "$1"` )
    for x in ${passed_array[@]} #1
    do 
	echo "Searching $x for 'Download Image' "
	DownloadImage=$( grep "Download Image" "$x" | sed 's/.*download-button" href="//' | sed 's/" onclick.*//' )
	if [ "$DownloadImage" != "" ]
	then 
#we don't want our variable to be quoted otherwise we'll get a Scheme missing error from wget
	    wget -nc -U Mozilla --referer=http://deviantart.com  --cookies=on --load-cookies=/home/arch-nicky/cookies.txt --keep-session-cookies --save-cookies=/home/arch-nicky/cookies.txt $DownloadImage
	fi
    done
}

function downloadallowingclobber ()
{
    passed_array=( `echo "$1"` )
    for x in ${passed_array[@]} 
    do 
	echo "$x"
	wget -U Mozilla --referer=http://deviantart.com  --cookies=on --load-cookies=/home/arch-nicky/cookies.txt --keep-session-cookies --save-cookies=/home/arch-nicky/cookies.txt "$x"
    done

}


function downloadnoclobber ()
{
    passed_array=( `echo "$1"` )
    for x in ${passed_array[@]} 
    do 
	echo "$x"
	wget -U Mozilla -nc  --referer=http://deviantart.com  --cookies=on --load-cookies=/home/arch-nicky/cookies.txt --keep-session-cookies --save-cookies=/home/arch-nicky/cookies.txt "$x"
    done
}

#####################
# BEGIN MAIN SCRIPT #
#####################X
Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then 
    echo "Usage: DeviantArtGalleryScraper deviantID <deviantID> ..."
else
    until [ -z "$1" ] #loop through all arguments using shift to move through arguments
    do 

	offsetcounter=0

#create a directory with the deviantID and move into it for saving of images
	echo "Making directory ${1} and moving into it"
	mkdir "$1"
	cd "$1"
	
#get gallery index
	echo "Getting gallery index file"
#without the trailing / it saves the file as gallery instead of index.html
	wget -U Mozilla --referer=http://deviantart.com  --cookies=on --load-cookies=/home/arch-nicky/cookies.txt --keep-session-cookies --save-cookies=/home/arch-nicky/cookies.txt  http://${1}.deviantart.com/gallery/ #-O $OutputFile
#check if the gallery index has additional pages.
	NextPageCheck=$(grep "gallery/?offset=" index.html | grep "Next" )
#2011.06.21 appears they no longer put "next page" they just do next. grep "Next Page</a>" )
#echo "$NextPageCheck"	

#grab all pages of the gallery
	while [ "$NextPageCheck" != "" ]
	do 
	    
	    let 'offsetcounter+=1'
	    let "offset=${offsetcounter} * 24"
	    echo "Getting gallery index with offset of ${offset}"
	    wget -U Mozilla http://${1}.deviantart.com/gallery/?offset=${offset} 
	    NextPageCheck=$(grep "gallery/?offset=" index.html?offset=${offset}  | grep "Next") # Page</a>" )
	    cat index.html?offset=${offset} >> index.html
	done
	echo "Done getting all gallery pages."

#compile arrays of the links to the fullimg, img, address of webpage, webpage file	
	Super_FullImg=$( grep super_fullimg index.html | sed 's/.*super_fullimg="//' | sed 's/" .*//' | tr -d '\n' )
grep super_fullimg index.html | sed 's/.*super_fullimg="//' | sed 's/" .*//'  > /tmp/Super_FullImg.txt
	Super_Img=$( grep super_img index.html | sed 's/.*super_img="//' | sed 's/" .*//' | tr '\n' ' '  )
	grep super_img index.html | sed 's/.*super_img="//' | sed 's/" .*//'  > /tmp/Super_Img.txt
	DataSrc=$( grep data-src index.html | sed 's/.*data-src="//;s/".*//' | tr '\n' ' ' )
	grep data-src index.html | sed 's/.*data-src="//;s/".*//'  > /tmp/DataSrc.txt
	#echo "Super_Img:$Super_Img"
	#echo "Super_FullImg:$Super_FullImg"
	#echo "DataSrc:$DataSrc"
	SortUniqSuper_Img=`sort /tmp/Super_Img.txt | uniq  `
	SortUniqDataSrc=`sort /tmp/DataSrc.txt | uniq `


	if [ $GetFullSizeImages -eq 1 ]
	then 

	    HrefAddress=$( grep "deviantart.com/art/"  index.html | sed 's/.*<a href="//' | sed 's/" class=.*//' )
	    HrefPageName=$( grep "deviantart.com/art/"  index.html | sed 's/.*<a href="//' | sed 's/" class=.*//' | sed 's/.*art\"///' )
	    DeletePageList=${HrefPageName}
#first download the pages of each image, then attempt to download the full image.  There is no other way that I know of to guarantee getting the fullsize image without visiting the individual webpage and checking if there is a "Download Image" button present. Otherwise simply going off the gallery webpage might only get you the "super_fullimg" when there is a larger version available.	

	    downloadIndividualPages "$HrefAddress" #need the quotes otherwise only the first element is sent
	    downloadFullImageFromFile "$HrefPageName"	
	    echo "Begin deleting files:"
	    echo $DeletePageList
	    removeIndividualPages "$DeletePageList"
	    echo "End deleting Files"
	    echo "Done compiling fullimg and img lists."
	fi
#Since the full images are first priority, we now try to get the fullimg then img listed in the gallery index file (as they are of lower res)	
	if [ $GetLargeImages -eq 1 ]
	then 
	    if [ "$Super_FullImg" != "" ]
	    then
#	    downloadallowingclobber "$Super_FullImg" 
		downloadnoclobber "$Super_FullImg" 
	    fi
	fi	

	if [ "$Super_Img" != "" ]
	then 
#	    downloadnoclobber "$Super_Img" 
	    echo "viewing Super Images"
	    feh ${SortUniqSuper_Img} & 
	fi

	if [ "$DataSrc" != "" ]
	then
	    echo "viewing Data Src Images"
	    feh ${SortUniqDataSrc} &
#	    downloadnoclobber "$DataSrc" #this catches all the ones that don't have superimages
#echo "$DataSrc"
	fi
# ??not sure this works or what it is supposed to do	rm `ls | grep -v '\.'` #use this to rm files since my above comd wasn't working
	rm index.html?offset*
	cd ..
	shift 
#this shifts the input parameters over one position.  pg 38 of bash guide. http://tldp.org/LDP/LG/issue25/dearman.html
    done
fi
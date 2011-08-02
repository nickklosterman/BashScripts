#!/bin/bash

#I think this version is simplified from the previous version. Before I had a separate function for the mature stuff but here I use the thumbnail address (which I was keying off for the mature content) for all the images. 
#NOTE::you can't be logged in and view the source and go off that bc diff pages are served to you when you are logged in vs this script which isn't logged in
#2011.06.23 It appears that DA wised up and now you can't just chop the 150 from the url to get the mature version. Only the thumbnail is accessible without brutefocring the URL. Which we'll be doing.


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
	newdirectory=${1}-favourites
#create a directory with the deviantID and move into it for saving of images
	echo "Making directory ${newdirectory} and moving into it"
	mkdir "$newdirectory"
	cd "$newdirectory"
	
#get fav index
	echo "Getting favourites index file"
#without the trailing / it saves the file as gallery instead of index.html
	wget -U Mozilla  http://${1}.deviantart.com/favourites/ #-O $OutputFile
#check if the gallery index has additional pages.
	NextPageCheck=$(grep "favourites/?offset=" index.html | grep "Next" )
#2011.06.21 appears they no longer put "next page" they just do next. grep "Next Page</a>" )
#echo "$NextPageCheck"	

#grab all pages of the gallery
	while [ "$NextPageCheck" != "" ]
	do 
	    
	    let 'offsetcounter+=1'
	    let "offset=${offsetcounter} * 24"
	    echo "Getting gallery index with offset of ${offset}"
	    wget -U Mozilla http://${1}.deviantart.com/favourites/?offset=${offset} 
	    NextPageCheck=$(grep "favourites/?offset=" index.html?offset=${offset}  | grep "Next") # Page</a>" )
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



	if [ "$Super_Img" != "" ]
	then 

	    echo "viewing Super Images"
	    feh ${SortUniqSuper_Img} & 
	fi

	if [ "$DataSrc" != "" ]
	then
	    echo "viewing Data Src Images"
	    feh ${SortUniqDataSrc} &

	fi
	rm index.html?offset*
	cd ..
	shift 
#this shifts the input parameters over one position.  pg 38 of bash guide. http://tldp.org/LDP/LG/issue25/dearman.html
    done
fi
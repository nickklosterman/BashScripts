#!/bin/bash

function getInstagramImages()
{
    tmpinstagram=$1
    tempinstagrampage=/tmp/tempinstagrampage

    while read LINE
    do 
	echo $LINE
	wget $LINE -O $tempinstagrampage
	url=$(grep class=\"photo\" $tempinstagrampage | sed 's/.*src="//;s/" alt.*//')
	echo $url
	wget $url

    done < $tmpinstagram

}



Number_Of_Expected_Args=1
if [ $# -ne $Number_Of_Expected_Args ]
then 
    echo "Usage: $0 www.blogurl.com "
else
    tmptumblr=/tmp/tumblr
    tmpinstagram=/tmp/instagram
    tmpfilelist=filelist.txt
    url=$1
#obtain the initial webpage 
    wget "$url" -O index.html -U Firefox
    counter=1

#	FileWebAddress=$( grep ">Older<" index.html )
#	FileWebAddress=$( grep "Older" index.html )
    FileWebAddress=$(grep "BEGIN POSTS" $counter.html -A 2 | grep "END POSTS" ) #this will return nothing until we go beyond the number of pages that there are postings on. 
    echo "++++++--"${FileWebAddress}"--++++++"

#    while [[ "$FileWebAddress" != "" ]] # use when using the "Older" paradigm
    while [[ "$FileWebAddress" == "" ]]
    do
#get subs files

	wget ${url}/page/${counter} -O ${counter}.html   #aagggh damnit, if I have 
#OB	FileWebAddress=$( grep ">Older<" $counter.html )
	FileWebAddress=$( grep "Older" $counter.html )  #this method isn't bullet proof. need a way to parse posts. if it is an empty page (a page beyond the true number of posts) then it will have <!-- BEGIN POSTS --> and <!-- END POSTS --> on lines with a blank line in between. 
	FileWebAddress=$(grep "BEGIN POSTS" $counter.html -A 2 | grep "END POSTS" ) #this will return nothing until we go beyond the number of pages that there are postings on. 
	let 'counter+=1' #for testing set this to a higher number to increment
    done

#have to specify the files this way since can't use regexp . For why check out : man bash and skip down to Pathname Expansion
#this will give an error if there are not 1,2, or 3 digit files.
    cat index.html [0-9].html [0-9][0-9].html [0-9][0-9][0-9].html > BLOG.html

    grep instagr.am/ BLOG.html | sed 's/.*href="//;s/">.*//'  > $tmpinstagram
#need to grep the individual instagram pages and look for -->grep class=\"photo\" instagrampage | sed 's/.*src=//;s/" alt.*/"/'

#  getInstagramImages $tmpinstagram

    if [[ 1 -eq 1 ]]
    then
#grep .media.tumblr BLOG.html | grep src | sed 's/.*src=/wget /;s/" alt.*/"/' > $tmptumblr  #this most likely just gets the preview images and not the full size images.
#bash $tmptumblr



	if [ -e $tmpfilelist ]
	then
	    echo "Overwriting $tmpfilelist"
	fi
	grep .media.tumblr BLOG.html | grep lightbox | sed 's/.*href="//;s/">.*//' > $tmpfilelist #get full size images
#	grep '<a id="post_' BLOG.html | sed 's/.*href="//;s/" >//' > $tmpfilelist
#	wget -i $tmpfilelist
# cd into an images directory or do some file cleanup before getting here so the html is separate from the images use pushd popd 
#wget -i $tmptumblr -nc
    fi


fi #end catching of num expected args


# Above was for skottie youngs tumblr that referenced his instagrams

# For Creaturebox.tumblr.com:
# I couldn't just grab the creaturebox.tumlbr.com page. It rejected wget without a useragent tag and then it handed back some split frames when I passed in a user agent string of Mozilla.  using a string of "Firefox" did get me what I wanted tho. this is a good resource : http://www.useragentstring.com/pages/useragentstring.php
# grep '<a id="post_' archive | sed 's/.*href="//;s/" >//' > filelist.txt
# wget -i filelist.txt
# cat * BLOGGG.html
# grep lightbox BLOGGG.html | sed 's/.*href="//;s/">.*//' > imagelist.txt; wget -i imagelist.txt

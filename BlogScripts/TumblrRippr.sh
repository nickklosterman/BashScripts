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
    echo "Usage: GetAllBlogPages.sh www.blogurl.com "
else
    tmptumblr=/tmp/tumblr
    tmpinstagram=/tmp/instagram
    url=$1
#obtain the initial webpage 
    wget "$url" -O index.html
    counter=1

    FileWebAddress=$( grep ">Older<" index.html )
    echo "++++++--"${FileWebAddress}"--++++++"

    while [[ "$FileWebAddress" != "" ]]
    do
#get subs files

	wget ${url}/page/${counter} -O ${counter}.html 
	FileWebAddress=$( grep ">Older<" $counter.html )
	let 'counter+=10'
    done

fi #end catching of num expected args

#have to specify the files this way since can't use regexp . For why check out : man bash and skip down to Pathname Expansion
#this will give an error if there are not 1,2, or 3 digit files.
cat index.html [0-9].html [0-9][0-9].html [0-9][0-9][0-9].html > BLOG.html

grep instagr.am/ BLOG.html | sed 's/.*href="//;s/">.*//'  > $tmpinstagram
#need to grep the individual instagram pages and look for -->grep class=\"photo\" instagrampage | sed 's/.*src=//;s/" alt.*/"/'

getInstagramImages $tmpinstagram

if [[ 1 -eq 0 ]]
then
#grep .media.tumblr BLOG.html | grep src | sed 's/.*src=/wget /;s/" alt.*/"/' > $tmptumblr
#bash $tmptumblr

grep .media.tumblr BLOG.html | grep src | sed 's/.*src="//;s/" alt.*//' > $tmptumblr
wget -i $tmptumblr -nc
fi


#!/bin/bash
function GetPageReturnFile()
{
#this function gets a webpage and echoes the name of the file that holds the desired text
    Webpage='/tmp/Qwertee' #`mktemp`
    wget ${1} -O ${Webpage} -q
    echo ${Webpage}
}

function GivePageReturnImage()
{
    Webpage=${1}
    OutputText=`grep "splash-picture-actual" ${Webpage} | grep "lightbox" | sed 's/.*href=\"/http:\/\/qwertee.com/' | sed 's/".*//;s/ /%20/g' ` ;
    echo ${OutputText}
}

function GivePageReturnAdditionalArtistArt()
{
    Webpage=${1}
    OutputText=`grep "<a href=\"/product/" ${Webpage} | grep "img src" | sed 's/.*img src=\"/http:\/\/qwertee.com/;s/".*//'  ` ;
    echo ${OutputText}
}

function cleanup()
{
if [ /tmp/Qwertee -e ]
then
rm /tmp/Qwertee
fi
exit 1
}

#without the http part feh can't tell its a url and doesn't know how to handle it. the http tells it to use internet protocols.

#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------

trap cleanup SIGINT
Qwertee=$(GetPageReturnFile http://qwertee.com )
#Description

Detail=$(GivePageReturnImage ${Qwertee} )

feh "${Detail}" & 
#echo "How fucking cool is that. You can feed feh the url of an image (or a list of urls) and it'll display the images!"
echo "wget ${Detail}"
AddlArt=$(GivePageReturnAdditionalArtistArt ${Qwertee} )
feh ${AddlArt} &
echo "wget ${AddlArt}"
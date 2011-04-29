#!/bin/bash
function GetPageReturnFile()
{
#this function gets a webpage and echoes the name of the file that holds the desired text
    Webpage=`mktemp`
    wget ${1} -O ${Webpage} -q
    echo ${Webpage}
}

function GivePageReturnImage()
{
    Webpage=${1}
    OutputText=`grep "products_large_images" ${Webpage} |  sed 's/.*http/http/' | sed 's/".*//'  ` ;
    echo ${OutputText}

}
function GivePageReturnAdditionalArtistArt
{
    Webpage=${1}
    OutputText=`grep "images/articles" ${Webpage} |  sed 's/.*src=\"images\/articles\//http:\/\/www.teefury.com\/images\/articles\//' | sed 's/".*//'  ` ;
    echo ${OutputText}
}


#without the http part feh can't tell its a url and doesn't know how to handle it. the http tells it to use internet protocols.

#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------

Teefury=$(GetPageReturnFile http://teefury.com )
#Description

Detail=$(GivePageReturnImage ${Teefury} )

feh "${Detail}" & 
#echo "How fucking cool is that. You can feed feh the url of an image (or a list of urls) and it'll display the images!"
echo "wget ${Detail}"
AddlArt=$( GivePageReturnAdditionalArtistArt ${Teefury} )
feh "${AddlArt}" &
echo "wget ${AddlArt}"
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
    OutputText=`grep "splash-picture-actual" ${Webpage} | grep "lightbox" | sed 's/.*href=\"/http:\/\/qwertee.com/' | sed 's/".*//' | sed 's/ /%20/g' ` ;
    echo ${OutputText}

}

#without the http part feh can't tell its a url and doesn't know how to handle it. the http tells it to use internet protocols.

#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------

Qwertee=$(GetPageReturnFile http://qwertee.com )
#Description

Detail=$(GivePageReturnImage ${Qwertee} )

feh "${Detail}" & 
#echo "How fucking cool is that. You can feed feh the url of an image (or a list of urls) and it'll display the images!"
echo "wget ${Detail}"

#!/bin/bash
function GetPageReturnFile()
{
#this function gets a webpage and echoes the name of the file that holds the desired text
    Webpage='/tmp/REI' #`mktemp`
    wget ${1} -O ${Webpage} -q
    echo ${Webpage}
}
function GivePageReturnDescription()
{
    OutputText=`grep "meta name=\"keywords" ${1} | grep "content=" | sed 's/.*content="//g;s/".*//' `
    echo  ${OutputText}
}
function GivePageReturnPrice()
{
    OutputText=`grep "topPrice" ${1} -A 4 | grep "salePrice" |  sed 's/<[^>]*>//g' `
    echo  ${OutputText}
}

function cleanup
{
    if [ -e /tmp/Altrec ]
    then
	{
	    rm /tmp/Altrec
	}
    fi
}

function GivePageReturnImage()
{
    Webpage=${1}
#    OutputText=`grep "img id=\"swatchImage"  ${Webpage} |  sed 's/.*src=\"/http:\/\/www.altrec.com\//;s/".*//'` ;
    OutputText=`grep "img id=\"swatchImage"  ${Webpage}  |  sed 's/.*src=\"//;s/".*//'` ;
#http:\/\/www/http:\/\/static.altrec.com\//;s/".*//'` ;
    echo ${OutputText}
}


#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------

REI=$(GetPageReturnFile http://outlet.altrec.com/ )
GivePageReturnDescription ${REI}
GivePageReturnPrice ${REI}
Full=$(GivePageReturnImage ${REI} )
#echo ${Full}
feh ${Full} & 
cleanup
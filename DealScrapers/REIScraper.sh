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
    OutputText=`grep "deal-of-the-day" ${1} | sed 's/<[^>]*>//g' `
    echo  ${OutputText}
}
function GivePageReturnPrice()
{
    OutputText=`grep "dotdPrice" ${1} | sed 's/<[^>]*>//g' `
    echo  ${OutputText}
}

function cleanup
{
    if [ -e /tmp/REI ]
    then
	{
	    rm /tmp/REI
	}
    fi
}

function GivePageReturnImage()
{
    Webpage=${1}
    OutputText=`grep "skuimage"  ${Webpage} |  sed 's/.*http:/http:/' | sed 's/".*//'` ;
    echo ${OutputText}
}


#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------

REI=$(GetPageReturnFile http://www.rei.com/outlet/ )
GivePageReturnDescription ${REI}
GivePageReturnPrice ${REI}
Full=$(GivePageReturnImage ${REI} )
feh ${Full} & 
cleanup
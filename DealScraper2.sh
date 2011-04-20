#!/bin/bash

#This program scrapes the four deal websites and displays the current deal

function GetPageReturnText()
{
#this function gets a webpage and echoes the name of the file that holds the desired text
Webpage=`mktemp`
wget ${1} -O ${Webpage} -q
OutputText=`grep "<title>" ${Webpage} | sed 's/<title>//' | sed 's/<\/title>//' `
echo ${OutputText}
}

function GetPageReturnImage()
{
#this function gets a webpage and echoes the name of the file that holds the desired image
Webpage=`mktemp`
wget ${1} -O ${Webpage} -q
case ${1} in 
"http://www.steepandcheap.com") 
OutputText=`grep "item_image" ${Webpage} | sed 's/<div id=\"item_image\"><img src=\"//' | sed 's/".*//' `;;
"http://www.whiskeymilitia.com"|"http://www.chainlove.com"|"http://www.bonktown.com")
OutputText=`grep "mainimage" ${Webpage} | sed 's/<img name=\"mainimage\" src=\"//' | sed 's/".*//' `;;
esac
Image=`mktemp`
wget ${OutputText} -O ${Image} -q
echo ${Image}
}


# BEGIN MAIN PART OF SCRIPT
SteepAndCheapTemp=""
WhiskeyMilitiaTemp=""
BonktownTemp=""
ChainloveTemp=""
while [ 1 ] ; do 
    SteepAndCheap=$(GetPageReturnText http://www.steepandcheap.com )
    if [ "${SteepAndCheap}" != "${SteepAndCheapTemp}" ]
    then
	SteepAndCheapImage=$(GetPageReturnImage http://www.steepandcheap.com )
	echo ${SteepAndCheap} 
	notify-send "$SteepAndCheap" -i ${SteepAndCheapImage} -t 3
    fi
  
    WhiskeyMilitia=$(GetPageReturnText http://www.whiskeymilitia.com )
    if [ "${WhiskeyMilitia}" != "${WhiskeyMilitiaTemp}" ]
    then 
	WhiskeyMilitiaImage=$(GetPageReturnImage http://www.whiskeymilitia.com )
	echo ${WhiskeyMilitia}
	notify-send  "$WhiskeyMilitia" -i ${WhiskeyMilitiaImage} -t 3
    fi

    Bonktown=$(GetPageReturnText http://www.bonktown.com )
    if [ "${Bonktown}" != "${BonktownTemp}" ]
    then
	BonktownImage=$(GetPageReturnImage http://www.bonktown.com )
	echo ${Bonktown}
	notify-send  "$Bonktown" -i ${BonktownImage} -t 3
    fi

    Chainlove=$(GetPageReturnText http://www.chainlove.com )
    if [ "${Chainlove}" != "${ChainloveTemp}" ]
    then 
	ChainloveImage=$(GetPageReturnImage http://www.chainlove.com )
	echo ${Chainlove}
	notify-send  "$Chainlove" -i ${ChainloveImage} -t 3
    fi

    SteepAndCheapTemp=`echo ${SteepAndCheap}`
    WhiskeyMilitiaTemp=`echo ${WhiskeyMilitia}`
    BonktownTemp=`echo ${Bonktown}`
    ChainloveTemp=`echo ${Chainlove}`
   
    sleep 5m
done
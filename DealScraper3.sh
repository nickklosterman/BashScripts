#!/bin/bash

#This program scrapes the four deal websites and displays the current deal

function GetPageReturnFile()
{
}

function GivePageReturnText()
{}

function GivePageReturnImage()
{}

function GivePageReturnTotalQuantity()
{
TotalQuantity=`grep total_qty_bar.set_data( ${1} | sed 's/.*,//' | sed 's/).*//' `
echo ${TotalQuantity}
}

function GivePageReturnQuantityRemaining()
{
RemainingQuantity=`grep total_qty_bar.set_data( ${1} | sed 's/.*(//' | sed 's/,.*//' `
echo ${RemainingQuantity}
}

function GivePageReturnQuantityRemainingOfTotalQuantity()
{
QuantityRemainingOfTotalQuantity=`grep total_qty_bar.set_data( ${1} | sed 's/.*(//' | sed 's/).*/ left/' | sed 's/,/ of /'  `
echo ${QuantityRemainingOfTotalQuantity}
}

function GivePageReturnTimeRemainingOfTotalTime()
{
TimeRemainingOfTotalTime=`grep setupWMTimerBar ${1} | sed 's/.*(//' | sed 's/).*/ total/' | sed 's/,/ seconds left of /'  `
echo ${QuantityRemainingOfTotalQuantity}
}

function GivePageReturnDurationOfDealInMinutes()
{
DurationOfDeal=` grep "Time Remaining:" ${1} -A 4 | grep bar_full | sed 's/<[^>]*>//g' `
echo ${DurationOfDeal}
}

function GiveSecondsReturnMinutesAndSeconds()
{
    let "minutes = ${1} % 60"
    let "seconds = ${1} - (60 * ${minutes} )"
    if [ ${seconds} -lt 10 ]
    then 
	echo ${minutes}:0${seconds}
    elif
	echo ${minutes}:${seconds} #FML the seconds need to be padded with zeros
    fi
}


function GivePageReturnTimeRemainingInSeconds()
{
TimeRemainingInSeconds=`grep setupWMTimerBar ${1} | sed 's/.*(//' | sed 's/,.*//'   `
}

function GiveTimeReturnDealEndTime()
{}

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
	date
	notify-send "$SteepAndCheap" -i ${SteepAndCheapImage} -t 3
    fi
  
    WhiskeyMilitia=$(GetPageReturnText http://www.whiskeymilitia.com )
    if [ "${WhiskeyMilitia}" != "${WhiskeyMilitiaTemp}" ]
    then 
	WhiskeyMilitiaImage=$(GetPageReturnImage http://www.whiskeymilitia.com )
	echo ${WhiskeyMilitia}
	date
	notify-send  "$WhiskeyMilitia" -i ${WhiskeyMilitiaImage} -t 3
    fi
WILL NEED TO PERFORM CHECK TO SEE IF THE OUTPUT ISNT EMPTY DUE TO NOT REPORTING TIME LEFT ON ITEM -> STATE NO TIME LIMIT GIVEN
    Bonktown=$(GetPageReturnText http://www.bonktown.com )
    if [ "${Bonktown}" != "${BonktownTemp}" ]
    then
	BonktownImage=$(GetPageReturnImage http://www.bonktown.com )
	echo ${Bonktown}
	date
	notify-send  "$Bonktown" -i ${BonktownImage} -t 3
    fi

    Chainlove=$(GetPageReturnText http://www.chainlove.com )
    if [ "${Chainlove}" != "${ChainloveTemp}" ]
    then 
	ChainloveImage=$(GetPageReturnImage http://www.chainlove.com )
	echo ${Chainlove}
	date
	notify-send  "$Chainlove" -i ${ChainloveImage} -t 3
    fi

    SteepAndCheapTemp=`echo ${SteepAndCheap}`
    WhiskeyMilitiaTemp=`echo ${WhiskeyMilitia}`
    BonktownTemp=`echo ${Bonktown}`
    ChainloveTemp=`echo ${Chainlove}`
   
need to almost thread this so that each deal is being updated at just the right time.
Or just update all whenever the next deal goes up. Then find the new deal with the shortest time left and update again. And reevaluate again when that deal is up.
    sleep 5m
done
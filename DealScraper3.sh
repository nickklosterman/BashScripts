#!/bin/bash

#This program scrapes the four deal websites and displays the current deal
#It will determines which site has the next upcoming deal and waits until
#that site has a new deal before updating.
#It appears that time isn't linear across all websites as 
function GetPageReturnFile()
{
#this function gets a webpage and echoes the name of the file that holds the desired text
    Webpage=`mktemp`
    wget ${1} -O ${Webpage} -q
    echo ${Webpage}
}

function GivePageReturnText()
{
    OutputText=`grep "<title>" ${1} | sed 's/<title>//' | sed 's/<\/title>//' `
    echo ${OutputText}
}

function GivePageAndWebsiteReturnImage()
{
    Webpage=${1}
    case ${2} in  #key off website name to determine how to parse for image
	"http://www.steepandcheap.com") 
	    OutputText=`grep "item_image" ${Webpage} | sed 's/<div id=\"item_image\"><img src=\"//' | sed 's/".*//' `;;
	"http://www.whiskeymilitia.com"|"http://www.chainlove.com"|"http://www.bonktown.com")
	    OutputText=`grep "mainimage" ${Webpage} | sed 's/<img name=\"mainimage\" src=\"//' | sed 's/".*//' `;;
    esac
    Image=`mktemp`
    wget ${OutputText} -O ${Image} -q
    echo ${Image}
}

function GivePageReturnTotalQuantity()
{
    TotalQuantity=`grep total_qty_bar.set_data\( ${1} | sed 's/.*,//' | sed 's/).*//' `
    echo ${TotalQuantity}
}

function GivePageReturnQuantityRemaining()
{
    RemainingQuantity=`grep total_qty_bar.set_data\( ${1} | sed 's/.*(//' | sed 's/,.*//' `
    echo ${RemainingQuantity}
}

function GivePageReturnQuantityRemainingOfTotalQuantity()
{
    QuantityRemainingOfTotalQuantity=`grep total_qty_bar.set_data\( ${1} | sed 's/.*(//' | sed 's/).*/ left/' | sed 's/,/ of /'  `
    echo ${QuantityRemainingOfTotalQuantity}
}

function GivePageReturnTimeRemainingOfTotalTime()
{
    TimeRemainingOfTotalTime=`grep setupWMTimerBar ${1} | sed 's/.*(//' | sed 's/).*/ total/' | sed 's/,/ seconds left of /'  `
    echo ${TimeRemainingOfTotalTime}
}

function GivePageReturnDurationOfDealInMinutes()
{
    DurationOfDeal=` grep "Time Remaining:" ${1} -A 4 | grep bar_full | sed 's/<[^>]*>//g' `
    echo ${DurationOfDeal}
}

function GiveSecondsReturnMinutesAndSeconds()
{
    input=${1}
    echo ${1}
    if [ ${input} == "\r" ] # \n check if null with -z ${input}
    then 
	echo "Null time"
	input=99999
    fi
    let "minutes = ${1} / 60"
    let "seconds = ${1} % 60 "
#    echo ${minutes} ${seconds}
    if [ ${seconds} -lt 10 ];
    then 
	echo ${minutes}:0${seconds}
    else
	echo ${minutes}:${seconds} 
#FML the seconds need to be padded with zeros--well I suppose this is one way to do it
    fi
}


function GivePageReturnTimeRemainingInSeconds()
{
#two forms setupTimerBar or setupWMTimerBar
#    TimeRemainingInSeconds=`grep setupWMTimerBar ${1} | sed 's/.*(//' | sed 's/,.*//'   `
    TimeRemainingInSeconds=`grep "TimerBar" ${1} | sed 's/.*(//' | sed 's/,.*//'   `
#if the value somehow comes out negative then we'll just wait 5 more seconds and hit it again
    if [ ${TimeRemainingInSeconds} -lt 0 ]
    then
	TimeRemainingInSeconds=5
    fi
    echo ${TimeRemainingInSeconds}
}

function GiveTimeReturnDealEndTime()
{
echo "Emptyfornow"
}

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

#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------

#Initialize our temp variables so on first go round we compare and come up false so we update
SteepAndCheapTemp=""
WhiskeyMilitiaTemp=""
BonktownTemp=""
ChainloveTemp=""
while [ 1 ] ; do 
    SteepAndCheapPage=$(GetPageReturnFile http://www.steepandcheap.com)
SnCDurationOfDealInMinutes=$(GivePageReturnDurationOfDealInMinutes ${SteepAndCheapPage} )
#echo "Duration of Deal" ${SnCDurationOfDealInMinutes}
    SnCTimeRemainingOfTotal=$(GivePageReturnTimeRemainingOfTotalTime ${SteepAndCheapPage} )
#echo "Time remaining of total"  ${SnCTimeRemainingOfTotal}
    SteepAndCheapTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${SteepAndCheapPage} )
SnCTimeLeftSeconds=${SteepAndCheapTimeLeftSeconds}

 #   echo ${SteepAndCheapTimeLeftSeconds}
    SnCTimeLeftMinutesSeconds=$(GiveSecondsReturnMinutesAndSeconds ${SteepAndCheapTimeLeftSeconds})
  #  echo ${SnCTimeLeftMinutesSeconds}
    SnCQuantityRemaining=$(GivePageReturnQuantityRemainingOfTotalQuantity ${SteepAndCheapPage} )
    SnCQuantityRemaining=$(GivePageReturnQuantityRemaining ${SteepAndCheapPage} )
   # echo ${SnCQuantityRemaining}
    SnCTotalQuantity=$(GivePageReturnTotalQuantity ${SteepAndCheapPage} )
   # echo -n ${SnCTotalQuantity} ${SnCQuantityRemaining} 
    SnCQuantityRemainingOfTotalQuantity=$(GivePageReturnQuantityRemainingOfTotalQuantity ${SteepAndCheapPage} )
    #echo ${SnCQuantityRemainingOfTotalQuantity}
    Bobo=`echo -n ${SnCTimeRemainingOfTotal} ${SnCQuantityRemainingOfTotalQuantity}`
    #echo ${Bobo}
    Bobo=${SnCTimeRemainingOfTotal}" "${SnCQuantityRemainingOfTotalQuantity}
    #echo ${Bobo}
    SteepAndCheap=$(GetPageReturnText http://www.steepandcheap.com )
    if [ "${SteepAndCheap}" != "${SteepAndCheapTemp}" ]
    then
	SteepAndCheapImage=$(GetPageReturnImage http://www.steepandcheap.com )
	echo ${SteepAndCheap} 
#	date
	notify-send "$SteepAndCheap" -i ${SteepAndCheapImage} -t 3
    fi

    WhiskeyMiltiaPage=$(GetPageReturnFile http://www.whiskeymilitia.com)
    WMQuantityRemaining=$(GivePageReturnQuantityRemaining ${WhiskeyMilitiaPage} )
    WMTotalQuantity=$(GivePageReturnTotalQuantity ${WhiskeyMilitiaPage} )
    WMTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${WhiskeyMiltiaPage})
#echo "WM" ${WMTimeLeftSeconds}
    WhiskeyMilitia=$(GetPageReturnText http://www.whiskeymilitia.com )
    if [ "${WhiskeyMilitia}" != "${WhiskeyMilitiaTemp}" ]
    then 
	WhiskeyMilitiaImage=$(GetPageReturnImage http://www.whiskeymilitia.com )
	echo ${WhiskeyMilitia}
#	date
	notify-send  "$WhiskeyMilitia" -i ${WhiskeyMilitiaImage} -t 3
    fi
#    WILL NEED TO PERFORM CHECK TO SEE IF THE OUTPUT ISNT EMPTY DUE TO NOT REPORTING TIME LEFT ON ITEM -> STATE NO TIME LIMIT GIVEN
    BonktownPage=$(GetPageReturnFile http://www.bonktown.com)
    BTQuantityRemaining=$(GivePageReturnQuantityRemaining ${BonktownPage} )
    BTTotalQuantity=$(GivePageReturnTotalQuantity ${BonktownPage} )
    BTTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${BonktownPage})
#echo "BT"${BTTimeLeftSeconds}"-"
    Bonktown=$(GetPageReturnText http://www.bonktown.com )
    if [ "${Bonktown}" != "${BonktownTemp}" ]
    then
	BonktownImage=$(GetPageReturnImage http://www.bonktown.com )
	echo ${Bonktown}
#	date
	notify-send  "$Bonktown" -i ${BonktownImage} -t 3
    fi
   
    ChainlovePage=$(GetPageReturnFile http://www.chainlove.com)
    CLQuantityRemaining=$(GivePageReturnQuantityRemaining ${ChainlovePage} )
    CLTotalQuantity=$(GivePageReturnTotalQuantity ${ChainlovePage} )
    CLTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${ChainlovePage})
#echo "CL-"${CLTimeLeftSeconds}"-"
    Chainlove=$(GetPageReturnText http://www.chainlove.com )
    if [ "${Chainlove}" != "${ChainloveTemp}" ]
    then 
	ChainloveImage=$(GetPageReturnImage http://www.chainlove.com )
	echo ${Chainlove}
#	date
	notify-send  "$Chainlove" -i ${ChainloveImage} -t 3
    fi

    SteepAndCheapTemp=`echo ${SteepAndCheap}`
    WhiskeyMilitiaTemp=`echo ${WhiskeyMilitia}`
    BonktownTemp=`echo ${Bonktown}`
    ChainloveTemp=`echo ${Chainlove}`
    
#    need to almost thread this so that each deal is being updated at just the right time.
#    Or just update all whenever the next deal goes up. Then find the new deal with the shortest time left and update again. And reevaluate again when that deal is up.
    SleepTime=${SnCTimeLeftSeconds}
    NextDeal="SteepAndCheap"
    if [ ${WMTimeLeftSeconds} -lt ${SleepTime} ]
    then
	SleepTime=${WMTimeLeftSeconds}
	NextDeal="WhiskeyMilitia"
    elif [ ${BTTimeLeftSeconds} -lt ${SleepTime} ] 
    then
	SleepTime=${BTTimeLeftSeconds}
	NextDeal="Bonktown"
    elif [ ${CLTimeLeftSeconds} -lt ${SleepTime} ]
    then
	SleepTime=${CLTimeLeftSeconds} 
	NextDeal="Chainlove"
    fi
#it'd be nice if we could print the time ticking down and then refresh with the new deals. use "print" maybe?
#echo "Sleeping for ${SleepTime} seconds"
SleepTimeMinutesSeconds=$(GiveSecondsReturnMinutesAndSeconds ${SleepTime})
echo "Next deal at ${NextDeal} in ${SleepTimeMinutesSeconds} minutes"
echo "SnC:${SnCTimeLeftSeconds} (${SnCQuantityRemaining}/${SnCTotalQuantity})  WM:${WMTimeLeftSeconds} (${WMQuantityRemaining}/${WMTotalQuantity}) BT:${BTTimeLeftSeconds} (${BTQuantityRemaining}/${BTTotalQuantity}) CL:${CLTimeLeftSeconds} (${CLQuantityRemaining}/${CLTotalQuantity})"
    sleep ${SleepTime}s
#sleep 5m
done


#Add items up for sale to a database. it should include item, price, percent off, and date of deal- put in sqlite database
#have it ignore womens/mens items 
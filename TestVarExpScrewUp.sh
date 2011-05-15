#!/bin/bash

#What I thought were errors weren't....
#Bug 1) At the end I thought the variable $SleepTimeMinutesSeconds was alsosomehow printing $SleepTime as well. This was not the case. The GiveTimeInSecondsReturnMinutesAndSeconds had an extra echo statement that echoed teh input variable in teh very begging as well as the proper output later.
#Bug 2) Again I thought some craziness was gonig on where the varaibles having common names like SnCTimeLeftSeconds WMTimeLeftSeconds or SteepAndCheapPage WhiskeyMilitiaPage were overwriting each other. It was really the fact that in the GetPageReturnFile function I only create one temp WebsitePage file. So all variables are pointing to that one temp file although it is being overwritten multiple times. I should've written it so that each page gets a unique file. Well it was when I was using mktemp....but then that filled up the HDD.


function GetPageReturnFile()
{
#this function gets a webpage and echoes the name of the file that holds the desired text
    Webpage='/tmp/WebsitePage' #`mktemp`
    wget ${1} -O ${Webpage} -q
    echo ${Webpage}
}

function GivePageReturnText()
{
    OutputText=`grep "<title>" ${1} | sed 's/<title>//' | sed 's/<\/title>//' `
    echo ${OutputText}
}

function GivePageReturnTimeRemainingOfTotalTime()
{
    TimeRemainingOfTotalTime=`grep setupWMTimerBar ${1} | sed 's/.*(//' | sed 's/).*/ total/' | sed 's/,/ seconds left of /'  `
    echo ${TimeRemainingOfTotalTime}
}


function GiveSecondsReturnMinutesAndSeconds()
{
    input=${1}
#    echo ${1}
    if [ "${1}" == "" ] # \n check if null with -z ${input}
    then 
	echo "Null time"
	input=99999
    fi
    let "minutes = ${1} / 60"
    let "seconds = ${1} % 60 "

    if [ ${seconds} -lt 10 ];
    then 
	echo ${minutes}:0${seconds}
    else
	echo ${minutes}:${seconds} 
#FML the seconds need to be padded with zeros--well I suppose this is one way to do it
    fi
}

#Input: webpage file
#output: extracts time remaining of the item for sale on the page
function GivePageReturnTimeRemainingInSeconds()
{
    TimeRemainingInSeconds=`grep "TimerBar" ${1} | sed 's/.*(//' | sed 's/,.*//'   `
#if the value somehow comes out negative then we'll just wait X more seconds and hit it again    
    if [ ${TimeRemainingInSeconds} -lt 0 ]
    then
	TimeRemainingInSeconds=4
    fi
    echo ${TimeRemainingInSeconds}
}

function GiveTimeInSecondsReturnDealEndTime()
{
#this was found here:http://www.askdavetaylor.com/date_math_in_linux_shell_script.html about 2/3 of the way down you'll see a post by marcus that is where it came from                                                                                                                                                 
NumDaysAdjust=0
Output=`date --date @$(($(date +%s)-(3600*24*${NumDaysAdjust})+${1} )) +%T`
echo ${Output}
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
    SteepAndCheap=$(GivePageReturnText ${SteepAndCheapPage} )
    SCTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${SteepAndCheapPage})
#if there are changes to the item description then we update and print the new info
    if [ "${SteepAndCheap}" != "${SteepAndCheapTemp}" ]
    then
	echo ${SteepAndCheap} 
	SteepAndCheapTemp=`echo ${SteepAndCheap}`
    fi

    WhiskeyMilitiaPage=$(GetPageReturnFile http://www.whiskeymilitia.com)
    WhiskeyMilitia=$(GivePageReturnText ${WhiskeyMilitiaPage} )
    WMTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${WhiskeyMilitiaPage})

    if [ "${WhiskeyMilitia}" != "${WhiskeyMilitiaTemp}" ]
    then
	echo ${WhiskeyMilitia}
	WhiskeyMilitiaTemp=`echo ${WhiskeyMilitia}`
    fi

    BonktownPage=$(GetPageReturnFile http://www.bonktown.com)
    Bonktown=$(GivePageReturnText ${BonktownPage} )
    BTTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${BonktownPage})

    if [ "${Bonktown}" != "${BonktownTemp}" ]
    then
	echo ${Bonktown}
	BonktownTemp=`echo ${Bonktown}`
    fi
    
    ChainlovePage=$(GetPageReturnFile http://www.chainlove.com)
    Chainlove=$(GivePageReturnText ${ChainlovePage} )
    CLTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${ChainlovePage})
    if [ "${Chainlove}" != "${ChainloveTemp}" ]
    then
	echo ${Chainlove}
	ChainloveTemp=`echo ${Chainlove}`
    fi
    echo $SCTimeLeftSeconds $WMTimeLeftSeconds $BTTimeLeftSeconds $CLTimeLeftSeconds
#for some reason it appears that the XXXXPage was going out of scope and we were only using the last page seen..i.e. ChainlovePage for all the functions here.
    SCTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${SteepAndCheapPage})
#    echo $SCTimeLeftSeconds 
    WMTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${WhiskeyMilitiaPage})
#    echo $WMTimeLeftSeconds 
    BTTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${BonktownPage})
#    echo $BTTimeLeftSeconds 
    CLTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${ChainlovePage})
grep "Steep" "${SteepAndCheapPage}"
echo "1"
grep "Whiskey" "${WhiskeyMilitiaPage}"
echo "2"
grep "Bonktown" "${BonktownPage}"
echo "3"
grep "Chainlove" "${ChainlovePage}"
echo "4"

    echo ${SCTimeLeftSeconds} $WMTimeLeftSeconds $BTTimeLeftSeconds $CLTimeLeftSeconds

    SleepTime=${SCTimeLeftSeconds}
    NextDeal="SteepAndCheap"
    if [ ${WMTimeLeftSeconds} -lt ${SleepTime} ]
    then
	SleepTime=${WMTimeLeftSeconds}
	NextDeal="WhiskeyMilitia"
    fi
    if [ ${BTTimeLeftSeconds} -lt ${SleepTime} ] 
    then
	SleepTime=${BTTimeLeftSeconds}
	NextDeal="Bonktown"
    fi
    if [ ${CLTimeLeftSeconds} -lt ${SleepTime} ]
    then
	SleepTime=${CLTimeLeftSeconds} 
	NextDeal="Chainlove"
    fi

#it'd be nice if we could print the time ticking down and then refresh with the new deals. use "print" maybe?

#K    SleepTimeMinutesSeconds=$(GiveSecondsReturnMinutesAndSeconds ${SleepTime})
    SleepTimeMinutesSeconds=$(GiveSecondsReturnMinutesAndSeconds 66 )
    echo "Next deal at ${NextDeal} in ${SleepTimeMinutesSeconds} minutes from" `date +%T `
TimeSleep=${SleepTimeMinutesSeconds}
    echo "Next deal at ${NextDeal} in ${TimeSleep} minutes from" `date +%T `
    sleep ${SleepTime}s
    
done

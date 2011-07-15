#!/bin/bash

#This program scrapes the four deal websites and displays the current deal
#It will determines which site has the next upcoming deal and waits until
#that site has a new deal before updating.
#It appears that time isn't linear across all websites as 

function on_exit()
{
#remove temporary files
    echo "Ok, caught Ctrl-c, exiting after clean up"
    
    WebpageArray=( "/tmp/SteepAndCheapPage" "/tmp/WhiskeyMilitiaPage" "/tmp/BonktownPage" "/tmp/ChainlovePage" )
    for item in "${WebpageArray[@]}"
    do
	if [ -e  "${item}" ]
	then 
	    rm "${item}"
	fi
    done
    WebImage=( "/tmp/SteepAndCheap.jpg" "/tmp/WhiskeyMilitia.jpg" "/tmp/Chainlove.jpg" "/tmp/Bonktown.jpg" "/tmp/ProductImage")
    for item in "${WebImage[@]}"
    do
	if [ -e  "${item}" ]
	then 
	    rm "${item}"
	fi
    done
    #without the exit command we capture the Ctrl-C but we don't actually kill the process
    exit 1
}

function GiveWebsiteCodeGetWebpageTempFile()
{
    case ${2} in
        0)
            Webpage='/tmp/SteepAndCheapPage';;
        1)
            Webpage='/tmp/WhiskeyMilitiaPage';;
        2)
            Webpage='/tmp/BonktownPage';;
        3)
            Webpage='/tmp/ChainlovePage';;
    esac
    wget ${1} -O ${Webpage} 2>&1 | grep -q "200 OK"
    WgetExitStatus=$?
    if [ $WgetExitStatus -eq 0 ]
    then
        echo ${Webpage}
    else
        echo "Error"
    fi
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
    Image='/tmp/ProductImage' 
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
    DurationOfDeal=`grep "Time Remaining:" ${1} -A 4 | grep bar_full | sed 's/<[^>]*>//g' `
    echo ${DurationOfDeal}
}

function GiveSecondsReturnMinutesAndSeconds()
{
    input=${1}

#you need to quote the variable otherwise 
    if [ "${input}" == "" ] # \n check if null with -z ${input}
    then 
	echo "Null time"
	input=99999
    fi
    let "minutes = ${1} / 60"
    let "seconds = ${1} % 60 "

    printf "%d:%02d" ${minutes} ${seconds}

}

#Input: webpage file
#output: extracts time remaining of the item for sale on the page
function GivePageReturnTimeRemainingInSeconds()
{
#two forms setupTimerBar or setupWMTimerBar

    TimeRemainingInSeconds=`grep "TimerBar" ${1} | sed 's/.*(//' | sed 's/,.*//'   `
#if the value somehow comes out negative then we'll just wait X more seconds and hit it again
    if [ ${TimeRemainingInSeconds} -lt 0 ]
    then
	TimeRemainingInSeconds=2
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

function UploadFileToDjinniusDeals
{

    bash UploadFileToDjinniusDeals.sh "nM&^%4Yu" "${1}"
}

function DownloadDjinniusDealsIndex
{
    wget www.djinnius.com/Deals/index.html -O "${1}"
}

function GetTagLineNumber
{

    LineNumber=`eval grep -n "${1}" ${2} | sed 's/:.*//' `
#without the eval the pattern to search for, which contains a set of quotes to keep it all together, wasn't returning anything
    echo $LineNumber
}

function GetBeginningOfFileToLine
{
    Output=` head -n +${1} "${2}" `
    echo "${Output}"
}

function GetLineToEOF
{
    Output=` tail -n +${1} "${2}" `
#could also use "sed -n 'N,$p' filename"
    echo "${Output}"
}

function GetBonktownProductDescriptionBeginLineNumber
{
    Output=$( GetTagLineNumber "\"BT Product Description Begin\"" "${1}" )
}

function GetBonktownProductDescriptionEndLineNumber
{
    Output=$( GetTagLineNumber "BT Product Description End" "${1}" )
    echo "${Output}"
}

function GetBonktownTableBeginLineNumber
{
    Output=$( GetTagLineNumber "BT Table Begin" "${1}" )
    echo "${Output}"
}

function GetBonktownTableEndLineNumber
{
    Output=$( GetTagLineNumber "BT Table End" "${1}" )
    echo "${Output}"
}

function UpdateWebpage
{
    WebsiteCode=${1}
    ProductDescription="${2}"
    Webpage="${4}"
    TempImage="${3}"

    echo ${Webpage}
    Database="/home/nicolae/Desktop/sqlite_examples/test.db"

    NumberOfRecordsToDisplay=25
#Get webpage from site --keep a local version?
    case ${WebsiteCode} in  #key off website code
	0) 
	    ProductBegin="\"SnC Product Description Begin\""
	    ProductEnd="\"SnC Product Description End\""
	    TableBegin="\"SnC Table Begin\""
	    TableEnd="\"SnC Table End\""
	    ProductImage="/tmp/SteepAndCheap.jpg"
	    ;;
	1)
	    ProductBegin="\"WM Product Description Begin\""
	    ProductEnd="\"WM Product Description End\""
	    TableBegin="\"WM Table Begin\""
	    TableEnd="\"WM Table End\""
	    ProductImage="/tmp/WhiskeyMilitia.jpg"
	    ;;
	2)
	    ProductBegin="\"BT Product Description Begin\""
	    ProductEnd="\"BT Product Description End\""
	    TableBegin="\"BT Table Begin\""
	    TableEnd="\"BT Table End\""
	    ProductImage="/tmp/Bonktown.jpg"
	    ;;
	3)
	    ProductBegin="\"CL Product Description Begin\""
	    ProductEnd="\"CL Product Description End\""
	    TableBegin="\"CL Table Begin\""
	    TableEnd="\"CL Table End\""
	    ProductImage="/tmp/Chainlove.jpg"
	    ;;
    esac
    
#upload new product image
    cp "${TempImage}" "${ProductImage}"
    UploadFileToDjinniusDeals "${ProductImage}"
#update product description
    UpdateProductDescription "${Webpage}" "${ProductDescription}" "${ProductBegin}" "${ProductEnd}"
#update past deals table
    UpdateTable "${Webpage}" ${NumberOfRecordsToDisplay} "${TableBegin}" "${TableEnd}" "${Database}"
#upload updated webpage
    UploadDjinniusDealsIndex
}

function UploadDjinniusDealsIndex
{
    IndexFile="/home/nicolae/Desktop/index.html"
    UploadFileToDjinniusDeals ${IndexFile}
}

function UpdateTable
{
    Webpage="${1}"
    echo "Webpage" "${1}"
    NumberOfRecordsToDisplay="${2}"
    BeginTag="${3}" 
    EndTag="${4}"
    DatabaseName="${5}"

    BeginLineNumber=$( GetTagLineNumber "${BeginTag}" "${Webpage}" )
    EndLineNumber=$( GetTagLineNumber "${EndTag}" "${Webpage}" )
    echo $BeginLineNumber $EndLineNumber

    Top=$( GetBeginningOfFileToLine ${BeginLineNumber} "${Webpage}" )

    Bottom=$( GetLineToEOF ${EndLineNumber} "${Webpage}" )

    QueryResults=$( GetQueryResults "${DatabaseName}" ${WebsiteCode} ${NumberOfRecordsToDisplay} )

    Newline="\n"
    Output="${Top}""${Newline}""${QueryResults}""${Newline}""${Bottom}"
#could also use printf to insert the newline
    Output="${Top}
${QueryResults}
${Bottom}"

    echo "${Output}" > "${Webpage}"

}

function GetQueryResults
{
    DatabaseName="${1}"
    WebsiteCode=${2}
    NumberOfRecordsToDisplay=${3}

    Stuff="select product,price,percentOffMSRP,quantity,dealdurationinminutes,timeEnter from Backcountrydeals where websitecode=${WebsiteCode} order by Bkey desc limit ${NumberOfRecordsToDisplay}"

#for some reason it was having trouble expanding the quotes. To solve that i tried using eval but that seemed to not expand the variables so I had to do a two step approach.
    Output=`sqlite3 -html "${DatabaseName}" "${Stuff}" `
    echo "${Output}"
}

function UpdateProductDescription
{
    Webpage="${1}"
    ProductDescription="${2}"
    BeginTag="${3}" 
    EndTag="${4}"
    BeginLineNumber=$( GetTagLineNumber  "${BeginTag}" "${Webpage}" )
    EndLineNumber=$( GetTagLineNumber  "${EndTag}" "${Webpage}" )
    Top=$( GetBeginningOfFileToLine ${BeginLineNumber} "${Webpage}" )
    Bottom=$( GetLineToEOF ${EndLineNumber} "${Webpage}" )
    Output="${Top}
${ProductDescription}
${Bottom}"
    echo "${Output}" > "${Webpage}"

}

#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------

#Initialize our temp variables so on first go round we compare and come up false so we update
SteepAndCheapTemp=""
WhiskeyMilitiaTemp=""
BonktownTemp=""
ChainloveTemp=""
SteepAndCheapImageLocation="/tmp/SteepAndCheap.jpg"
WhiskeyMilitiaImageLocation="/tmp/WhiskeyMilitia.jpg"
BonktownImageLocation="/tmp/Bonktown.jpg"
ChainloveImageLocation="/tmp/Chainlove.jpg"
WebpageIndex="/home/nicolae/Desktop/index.html"
#clean up our temp files if we receive a kill signal
trap on_exit SIGINT 

while [ 1 ] ; do 

    SteepAndCheapPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.steepandcheap.com 0 )
    SnCDurationOfDealInMinutes=$(GivePageReturnDurationOfDealInMinutes ${SteepAndCheapPage} )
    SnCTimeRemainingOfTotal=$(GivePageReturnTimeRemainingOfTotalTime ${SteepAndCheapPage} )
    SteepAndCheapTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${SteepAndCheapPage} )
    SnCTimeLeftSeconds=${SteepAndCheapTimeLeftSeconds}
    SnCTimeLeftMinutesSeconds=$(GiveSecondsReturnMinutesAndSeconds ${SteepAndCheapTimeLeftSeconds})
    SnCQuantityRemaining=$(GivePageReturnQuantityRemainingOfTotalQuantity ${SteepAndCheapPage} )
    SnCQuantityRemaining=$(GivePageReturnQuantityRemaining ${SteepAndCheapPage} )
    SnCTotalQuantity=$(GivePageReturnTotalQuantity ${SteepAndCheapPage} )
    SnCQuantityRemainingOfTotalQuantity=$(GivePageReturnQuantityRemainingOfTotalQuantity ${SteepAndCheapPage} )
    SteepAndCheap=$(GivePageReturnText ${SteepAndCheapPage} )

#if there are changes to the item description then we update and print the new info
    if [ "${SteepAndCheap}" != "${SteepAndCheapTemp}" ]
    then
#obtain the image
	SteepAndCheapImage=$(GivePageAndWebsiteReturnImage ${SteepAndCheapPage} http://www.steepandcheap.com )
#output the text description in the terminal
	echo ${SteepAndCheap} 

	UpdateWebpage 0 "${SteepAndCheap}" "${SteepAndCheapImage}"  "${WebpageIndex}"
	SteepAndCheapTemp=`echo ${SteepAndCheap}`
    fi

    WhiskeyMilitiaPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.whiskeymilitia.com 1 )
    WMQuantityRemaining=$(GivePageReturnQuantityRemaining ${WhiskeyMilitiaPage} )

    WMTotalQuantity=$(GivePageReturnTotalQuantity ${WhiskeyMilitiaPage} )
    WMTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${WhiskeyMilitiaPage})
    WhiskeyMilitia=$(GivePageReturnText ${WhiskeyMilitiaPage} )

    if [ "${WhiskeyMilitia}" != "${WhiskeyMilitiaTemp}" ]
    then

	WhiskeyMilitiaImage=$(GivePageAndWebsiteReturnImage ${WhiskeyMilitiaPage} http://www.whiskeymilitia.com )
	echo ${WhiskeyMilitia}
	
	UpdateWebpage 1 "${WhiskeyMilitia}" "${WhiskeyMilitiaImage}"   "${WebpageIndex}"
	notify-send  "$WhiskeyMilitia" -i ${WhiskeyMilitiaImage} -t 3
	WhiskeyMilitiaTemp=`echo ${WhiskeyMilitia}`
    fi

    BonktownPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.bonktown.com 2 )
    BTQuantityRemaining=$(GivePageReturnQuantityRemaining ${BonktownPage} )
    BTTotalQuantity=$(GivePageReturnTotalQuantity ${BonktownPage} )
    BTTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${BonktownPage})
    Bonktown=$(GivePageReturnText ${BonktownPage} )

    if [ "${Bonktown}" != "${BonktownTemp}" ]
    then

	BonktownImage=$(GivePageAndWebsiteReturnImage ${BonktownPage} http://www.bonktown.com )
	echo ${Bonktown}
	UpdateWebpage 2 "${Bonktown}" "${BonktownImage}"  "${WebpageIndex}"
	notify-send  "$Bonktown" -i ${BonktownImage} -t 3
	BonktownTemp=`echo ${Bonktown}`
    fi
    ChainlovePage=$(GiveWebsiteCodeGetWebpageTempFile http://www.chainlove.com 3 )
    CLQuantityRemaining=$(GivePageReturnQuantityRemaining ${ChainlovePage} )
    CLTotalQuantity=$(GivePageReturnTotalQuantity ${ChainlovePage} )
    CLTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${ChainlovePage})
    Chainlove=$(GivePageReturnText ${ChainlovePage} )

    if [ "${Chainlove}" != "${ChainloveTemp}" ]
    then
	ChainloveImage=$(GivePageAndWebsiteReturnImage ${ChainlovePage} http://www.chainlove.com )
	echo ${Chainlove}
	UpdateWebpage 3 "${Chainlove}" "${ChainloveImage}" "${WebpageIndex}"
	notify-send  "$Chainlove" -i ${ChainloveImage} -t 3
	ChainloveTemp=`echo ${Chainlove}`
    fi

    SleepTime=${SnCTimeLeftSeconds}
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

    SleepTimeMinutesSeconds=$(GiveSecondsReturnMinutesAndSeconds ${SleepTime})
    DealEndTime=$( GiveTimeInSecondsReturnDealEndTime ${SleepTime} )
    echo "Next deal at ${NextDeal} in ${SleepTimeMinutesSeconds} minutes from" `date +%T ` "which occurs at ${DealEndTime}"

    echo "SnC:${SnCTimeLeftSeconds} (${SnCQuantityRemaining}/${SnCTotalQuantity})  WM:${WMTimeLeftSeconds} (${WMQuantityRemaining}/${WMTotalQuantity}) BT:${BTTimeLeftSeconds} (${BTQuantityRemaining}/${BTTotalQuantity}) CL:${CLTimeLeftSeconds} (${CLQuantityRemaining}/${CLTotalQuantity})"
    
    sleep ${SleepTime}s
done


#!/bin/bash

#This program scrapes the four deal websites and displays the current deal
#It will determines which site has the next upcoming deal and waits until
#that site has a new deal before updating.
#It appears that time isn't linear across all websites as 

#BASH programming caveats
#since there is no compiling I was having the program stop because I was trying to reference a variable that didn't exist bc I had spelled the name wrong.
#This just caused the program to stop dead in its tracks and not progress farther
#At the end you see that SleepTime gets printed as well as SleepTimeMinutesSeconds when I call to print SleepTimeMinutesSeconds. Maybe this has to do with variable name length being too long and too similar?
function on_exit()
{
#remove temporary files
echo "Ok, caught Ctrl-c, exiting after clean up"
if [ -e /tmp/WebsitePage  ]
then 
rm /tmp/WebsitePage
fi

if [ -e /tmp/ProductImage ] 
then 
rm /tmp/ProductImage
fi

if [ -e /tmp/SteepAndCheap.jpg ] 
then 
rm /tmp/SteepAndCheap.jpg
fi
if [ -e /tmp/WhiskeyMilitia.jpg ] 
then 
rm /tmp/WhiskeyMilitia.jpg
fi
if [ -e /tmp/Chainlove.jpg ] 
then 
rm /tmp/Chainlove.jpg
fi

if [ -e /tmp/Bonktown.jpg ] 
then 
rm /tmp/Bonktown.jpg
fi



#without the exit command we capture the Ctrl-C but we don't actually kill the process
exit 1
}

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

function GivePageAndWebsiteReturnImage()
{
    Webpage=${1}
    case ${2} in  #key off website name to determine how to parse for image
	"http://www.steepandcheap.com") 
	    OutputText=`grep "item_image" ${Webpage} | sed 's/<div id=\"item_image\"><img src=\"//' | sed 's/".*//' `;;
	"http://www.whiskeymilitia.com"|"http://www.chainlove.com"|"http://www.bonktown.com")
	    OutputText=`grep "mainimage" ${Webpage} | sed 's/<img name=\"mainimage\" src=\"//' | sed 's/".*//' `;;
    esac
    Image='/tmp/ProductImage' #`mktemp`
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
#echo "22"
    RemainingQuantity=`grep total_qty_bar.set_data\( ${1} | sed 's/.*(//' | sed 's/,.*//' `
#echo "33"
#printf " GivePageReturnQuantityRemaining()"
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
    echo ${1}
#you need to quote the variable otherwise 
    if [ "${input}" == "" ] # \n check if null with -z ${input}
    then 
	echo "Null time"
	input=99999
    fi
    let "minutes = ${1} / 60"
    let "seconds = ${1} % 60 "
#    echo ${minutes} ${seconds}
printf "%d:%02d" ${minutes} ${seconds}

#    if [ ${seconds} -lt 10 ];
#    then 
#	echo ${minutes}:0${seconds} #could've jsut used printf
#    else
#	echo ${minutes}:${seconds} 
#FML the seconds need to be padded with zeros--well I suppose this is one way to do it
#    fi
}

#Input: webpage file
#output: extracts time remaining of the item for sale on the page
function GivePageReturnTimeRemainingInSeconds()
{
#two forms setupTimerBar or setupWMTimerBar
#    TimeRemainingInSeconds=`grep setupWMTimerBar ${1} | sed 's/.*(//' | sed 's/,.*//'   `
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
#echo "in Upload"
bash UploadFileToDjinniusDeals.sh "nM&^%4Yu" "${1}"
}

function DownloadDjinniusDealsIndex
{
wget www.djinnius.com/Deals/index.html -O "${1}"
}

function GetTagLineNumber
{

#echo "in GetTagLineNumber"
#echo "${1}" "${2}"
LineNumber=`eval grep -n "${1}" ${2} | sed 's/:.*//' `
#without the eval the pattern to search for, which contains a set of quotes to keep it all together, wasn't returning anything
echo $LineNumber
}

function GetBeginningOfFileToLine
{
#echo ${1} "${2}"
Output=` head -n +${1} "${2}" `
echo "${Output}"
}

function GetLineToEOF
{
#echo ${1} "${2}"
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
#echo "Top" "${Top}"
Bottom=$( GetLineToEOF ${EndLineNumber} "${Webpage}" )
#echo "Bottom" "${Bottom}"
QueryResults=$( GetQueryResults "${DatabaseName}" ${WebsiteCode} ${NumberOfRecordsToDisplay} )
#echo "Query Results:" "${QueryResults}"

#this doesn't work
Newline="\n"
Output="${Top}""${Newline}""${QueryResults}""${Newline}""${Bottom}"
#could also use printf to insert the newline
Output="${Top}
${QueryResults}
${Bottom}"

echo "${Output}" > "${Webpage}"
#> /tmp/Bob.html #> "${Webpage}"
}

function GetQueryResults
{
DatabaseName="${1}"
WebsiteCode=${2}
NumberOfRecordsToDisplay=${3}
#without the eval we get a syntax error
#Stuff="\"select product,price,percentOffMSRP,quantity,dealdurationinminutes,timeEnter from Backcountrydeals where websitecode=${WebsiteCode} order by Bkey desc limit ${NumberOfRecordsToDisplay}\""
Stuff="select product,price,percentOffMSRP,quantity,dealdurationinminutes,timeEnter from Backcountrydeals where websitecode=${WebsiteCode} order by Bkey desc limit ${NumberOfRecordsToDisplay}"
#echo "${Stuff}"  
#for some reason it was having trouble expanding the quotes. To solve that i tried using eval but that seemed to not expand the variables so I had to do a two step approach.
Output=`sqlite3 -html "${DatabaseName}" "${Stuff}" `
#`eval sqlite3 -html "${DatabaseName}" "${Stuf}" ` # gets hung up 
#"select product,price,percentOffMSRP,quantity,dealdurationinminutes,timeEnter from Backcountrydeals where websitecode="${WebsiteCode}" order by Bkey desc limit "${NumberOfRecordsToDisplay}"" ` 
#"select * from Backcountrydeals" ` 
#".table" ` 
 #"select product,price,percentOffMSRP,quantity,dealdurationinminutes,timeEnter from Backcountrydeals where websitecode=${WebsiteCode} order by Bkey desc limit ${NumberOfRecordsToDisplay}" ` 
#`eval sqlite3 -html "${DatabaseName}" "select product,price,percentOffMSRP,quantity,dealdurationinminutes,timeEnter from Backcountrydeals where websitecode=${WebsiteCode} order by Bkey desc limit ${NumberOfRecordsToDisplay}"`
echo "${Output}"
}

function UpdateProductDescription
{
Webpage="${1}"
ProductDescription="${2}"
BeginTag="${3}" 
EndTag="${4}"
#echo $Webpage
BeginLineNumber=$( GetTagLineNumber  "${BeginTag}" "${Webpage}" )
#echo "BeginLineNumber" $BeginLineNumber
EndLineNumber=$( GetTagLineNumber  "${EndTag}" "${Webpage}" )
#echo "EndLineNumber" $EndLineNumber
Top=$( GetBeginningOfFileToLine ${BeginLineNumber} "${Webpage}" )
#echo "Top" $Top
Bottom=$( GetLineToEOF ${EndLineNumber} "${Webpage}" )
#echo "Bottom" $Bottom
#Newline="\n"
#Output="${Top}""${Newline}""${ProductDescription}""${Newline}""${Bottom}"
Output="${Top}
${ProductDescription}
${Bottom}"
echo "${Output}" > "${Webpage}"
#> /tmp/Bob1.html # 
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
    #trap on_exit SIGKILL
    #trap on_exit SIGTERM
    trap on_exit SIGINT #2
    #on_exit
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

    SteepAndCheap=$(GivePageReturnText ${SteepAndCheapPage} )

#if there are changes to the item description then we update and print the new info
    if [ "${SteepAndCheap}" != "${SteepAndCheapTemp}" ]
    then
#obtain the image
	SteepAndCheapImage=$(GivePageAndWebsiteReturnImage ${SteepAndCheapPage} http://www.steepandcheap.com )
#output the text description in the terminal
	echo ${SteepAndCheap} 

	UpdateWebpage 0 "${SteepAndCheap}" "${SteepAndCheapImage}"  "${WebpageIndex}"

	#rm ${SteepAndCheapImageLocation} I can't use this bc I delete the file before I'm done uploading it
#send out the info using notify-send for a popup
#	notify-send "$SteepAndCheap" -i ${SteepAndCheapImage} -t 3
#copy content to our temp holder so we can see if things changed.
	SteepAndCheapTemp=`echo ${SteepAndCheap}`
    fi

    WhiskeyMilitiaPage=$(GetPageReturnFile http://www.whiskeymilitia.com)

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

    BonktownPage=$(GetPageReturnFile http://www.bonktown.com)
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
    
    ChainlovePage=$(GetPageReturnFile http://www.chainlove.com)
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






    #I had been making a logic error here for quite some time.
#I didn't understand why sometimes the "math" would be off and a smaller value wouldn't be assigned to the SleepTime
#It was due to me using a if.then.elif.then.elif.then cascade. I was
#mistakenly thinking that this was the correct method to get the smallest value
#into SleepTime. This was wrong because if WMTimeLeftSeconds was smaller than 
#the one for SnC then it would be assigned to SLeepTime and it would kick out of the loop. As long as ONE of the conditions held it'd kick out and not go futher and evaluate any more of the logic tests. DUH. yet this took me a while to figure out.
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
    echo "Next deal at ${NextDeal} in ${SleepTimeMinutesSeconds} minutes from" `date +%T `
DealEndTime=$( GiveTimeInSecondsReturnDealEndTime ${SleepTime} )
echo ${DealEndTime}
    echo "SnC:${SnCTimeLeftSeconds} (${SnCQuantityRemaining}/${SnCTotalQuantity})  WM:${WMTimeLeftSeconds} (${WMQuantityRemaining}/${WMTotalQuantity}) BT:${BTTimeLeftSeconds} (${BTQuantityRemaining}/${BTTotalQuantity}) CL:${CLTimeLeftSeconds} (${CLQuantityRemaining}/${CLTotalQuantity})"



    sleep ${SleepTime}s


done


#Add items up for sale to a database. it should include item, price, percent off,quantity,time duration of sale and date of deal- put in sqlite database
#have it ignore womens/mens items 
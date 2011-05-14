#!/bin/bash

#This program scrapes the four deal websites and displays the current deal
#It will determines which site has the next upcoming deal and waits until
#that site has a new deal before updating.
#It appears that time isn't linear across all websites as 

#BASH programming caveats
#since there is no compiling I was having the program stop because I was trying to reference a variable that didn't exist bc I had spelled the name wrong.
#This just caused the program to stop dead in its tracks and not progress farther
#At the end you see that SleepTime gets printed as well as SleepTimeMinutesSeconds when I call to print SleepTimeMinutesSeconds. Maybe this has to do with variable name length being too long and too similar?

function checknet()
{
#this doesn't seem super robust but I suppose it works
if eval "ping -c 1 www.djinnius.com > /dev/null"; then
    echo "1"
else
    echo "0"
fi
}

function checkdiskspace()
{
    diskspacelimit=$2
    DiskSpace=$(df -h "${1}" | grep -v Filesystem | awk '{ print $4  }' )
    digits=$(df -h "${1}" | grep -v Filesystem | awk '{ print $4  }'| sed 's/.$//' )
    BytesLetter=$(df -h  "${1}" | grep -v Filesystem | awk '{ print $4  }'| sed 's/[0-9]//g' )

    Output=0    

    case $BytesLetter in
	"K")
	    Output=0;;
	"M")
	    Output=1
            if [ $digits -lt  $diskspacelimit ]
            then 
		Output=0
            fi;;
	*) #account for Gigs and Terabytes etc of space 
	    Output=1;;
    esac
    echo ${Output}
}

function checktmpdiskspace()
{
Output=$(checkdiskspace /tmp 10 )
echo ${Output}
}

function checkhomediskspace()
{
#check that /home has at least 10MB fo storage available
Output=$(checkdiskspace /home 10 )
echo ${Output}
}

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

function GivePageReturnProductDescription()
{
#for the possessive form I need to replace the single quote with double single quotes

#    OutputText=`grep "<title>" ${1} |  sed 's/\<title\>(Steep and Cheap:|WhiskeyMilitia.com:|BonkTown.com:|Chainlove.com:) //' | sed 's/ - \$.*//' | sed 's/\x27/\x27\x27/g' ` #not sure why this didn't work

OutputText=`grep "<title>" ${1} |  sed -n 's/[^:]*://p' | sed 's/ - \$.*//' | sed 's/\x27/\x27\x27/g' ` #this was causing problems with descriptions that had multiple instances of the colon i.e. there was a colon in the description that caused the front part  of the description to be cut off.
#Explanation: replace everything up to the colon that isn't a colon with nothing, print the rest

#    OutputText=`grep "<title>" ${1} |  sed 's/.*: //' | sed 's/ - \$.*//' | sed 's/\x27/\x27\x27/g' ` #this was causing problems with descriptions that had multiple instances of the colon i.e. there was a colon in the description that caused the front part  of the description to be cut off.

# tr -d "'" ` this worked but I wanted to still have the apostrophe in the output
#sed 's/"'"/\\"'"/' ` this didn't work as it kept giving an error ->unexpected EOF while looking for matching `''
 #the database was chocking on apostrophes in the variable as the single quote signals the end of a command so needs to be preceded by another single quote to escape it
# then the problem arose as bash being ended by the single quote we put in there. other bash/sed solutions to this
# for it to work you had to create a quote variable "'" and then sub that in to a double quoted sed expression sed "s/$quote/stuff/g" inputfile. The above method seemed more straightforward using the hex character codes
#also check out the singleapostrophetodoubleapostrophetest.sh file I wrote

    echo ${OutputText}
}

function GivePageReturnPrice()
{
    OutputText=`grep "<title>" ${1} | sed 's/.*[\$]//' | sed 's/- .*//' `
    echo ${OutputText}
}

function GivePageReturnPercentOffMSRP()
{
    OutputText=`grep "<title>" ${1} |  sed 's/.* - //' | sed 's/%.*//' `
# or could use the tag stripping command of sed 's/<[^>]*>//g'                                                                                         
# sed 's/.*: //' -> remove website prefix                                                                                                              
# grep "<title>" /home/nicolae/index.html.1 | sed 's/.*: //' -> obtain main info w/o website prefix. but has trailling </title> tag                    
# grep "<title>" /home/nicolae/index.html.1 | sed 's/.*: //' | sed 's/.* - //' | sed 's/%.*//' -> obtain percent off                                   
# grep "<title>" /home/nicolae/index.html.1 | sed 's/.*: //' | sed 's/.* - \$//' | sed 's/- .*//' ->obtain price w/o dollar sign --this worked in the terminal but in the script I had to put the $ in [\$]                      
# grep "<title>" /home/nicolae/index.html.1 | sed 's/.*: //' | sed 's/ - \$.*//' -> obtain  product description                                        
    echo ${OutputText}
}

GiveDatabaseTablenameDataEnterIntoDatabase()
{
sqlite3 ${1} "insert into ${2} (websiteCode, product, price, percentOffMSRP, quantity, dealdurationinminutes) values ( '${3}', '${4}', '${5}', '${6}', '${7}', '${8}' );"
}



function GiveWebsiteAndDatabaseReturnWebsiteCodeFromDatabase()
{
Website=${1}
Database=${2}

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
    TotalQuantity=`grep total_qty_bar.set_data\( ${1} | sed 's/.*,//;s/[)].*//' `
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
    DurationOfDeal=` grep "Time Remaining:" ${1} -A 4 | grep bar_full | sed 's/<[^>]*>//g' `
    if [ "${DurationOfDeal}" == "" ]
    then
#then its teh alternate time form
	DurationOfDeal=`grep "total_time" ${1} | sed 's/<[^>]*//g; s/[^0-9]//g' `
#first we grep for total_time then remove html tags then remove everything but the numbers
#to just capture all numbers add a * after the pattern
    fi
    echo ${DurationOfDeal}
}

function GiveSecondsReturnMinutesAndSeconds()
{
    input=${1}
    echo ${1}
#YOU WEREN"T QUOTING YOUR VARIABLE! THAT IS WHY THIS WAS FAILING
#    if [ ${input} == "\r" ] # \n check if null with -z ${input}
    if [ "${1}" == "" ] # \n check if null with -z ${input}
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

#Input: webpage file
#output: extracts time remaining of the item for sale on the page
function GivePageReturnTimeRemainingInSeconds()
{
#two forms setupTimerBar or setupWMTimerBar
#    TimeRemainingInSeconds=`grep setupWMTimerBar ${1} | sed 's/.*(//' | sed 's/,.*//'   `
    TimeRemainingInSeconds=`grep "TimerBar" ${1} | sed 's/.*(//' | sed 's/,.*//'   `
#if the value somehow comes out negative then we'll just wait X more seconds and hit it again

    Quantity=$(GivePageReturnTotalQuantity ${1} )
    if [ $Quantity -lt 5 ] 
    then
# if there is a low quantity we run the risk of the item selling out and moving on to the next deal so we set the timer manually just in case this happens
	TimeRemainingInSeconds=180 # 3minutes
    else
	if [ ${TimeRemainingInSeconds} -lt 0 ]
	then
	    TimeRemainingInSeconds=4
	fi
    fi
    echo ${TimeRemainingInSeconds}
}

function GiveTimeReturnDealEndTime()
{
    echo "Emptyfornow"
}


function GiveWebPageKeywordTextEmailListFilethenNotify()
{
#echo "${1}" "${2}"
while read keyword phonenumber email
do 
#Match=$( echo `expr match "${keyword}" "${1}" ` ) #for some reason I couldn't get these substring matching routines to work
#Match=$( echo `expr index "${1}" "${keyword}" ` )
#echo ${Match}  ${keyword}
#if [ $Match -gt 0 ]
if  grep -q "${keyword}" <<<${1}   # we use the -q since we just want the exit code
then 
echo "We have a match at ${Match}"
echo "sending ${1} to ${phonenumber} and ${email}"
#    sendTexttoPhone "${1}" "$phonenumber" #quotes on phone not necessary...
#    sendEmail "${1}" "${email}"
fi
done < "${2}"
}

#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------

#Initialize our temp variables so on first go round we compare and come up false so we update
SteepAndCheapTemp=""
WhiskeyMilitiaTemp=""
BonktownTemp=""
ChainloveTemp=""
trap on_exit SIGINT

Datafile='Data.txt'

TmpDiskSpaceStatus=$( checktmpdiskspace )
HomeDiskSpaceStatus=$( checkhomediskspace )
NetStatus=$( checknet )
while [[ $TmpDiskSpaceStatus -eq 1 && $HomeDiskSpaceStatus -eq 1 && $NetStatus -eq 1 ]] ; do 
    SteepAndCheapPage=$(GetPageReturnFile http://www.steepandcheap.com)
    SteepAndCheap=$(GivePageReturnText ${SteepAndCheapPage} )

#if there are changes to the item description then we update and print the new info
    if [ "${SteepAndCheap}" != "${SteepAndCheapTemp}" ]
    then
	echo ${SteepAndCheap} 

#	GiveWebPageKeywordTextEmailListFilethenNotify ${SteepAndCheapPage} "${Datafile}"
	GiveWebPageKeywordTextEmailListFilethenNotify "${SteepAndCheap}" "${Datafile}"
	SteepAndCheapTemp=`echo ${SteepAndCheap}`
    fi

    WhiskeyMilitiaPage=$(GetPageReturnFile http://www.whiskeymilitia.com)
    WhiskeyMilitia=$(GivePageReturnText ${WhiskeyMilitiaPage} )


    if [ "${WhiskeyMilitia}" != "${WhiskeyMilitiaTemp}" ]
    then
	echo ${WhiskeyMilitia}
#	GiveWebPageKeywordTextEmailListFilethenNotify   ${WhiskeyMilitiaPage} "${Datafile}"
	GiveWebPageKeywordTextEmailListFilethenNotify  "${WhiskeyMilitia}" "${Datafile}"



	WhiskeyMilitiaTemp=`echo ${WhiskeyMilitia}`
    fi

    BonktownPage=$(GetPageReturnFile http://www.bonktown.com)
    Bonktown=$(GivePageReturnText ${BonktownPage} )


    if [ "${Bonktown}" != "${BonktownTemp}" ]
    then
	echo ${Bonktown}
#	GiveWebPageKeywordTextEmailListFilethenNotify ${BonktownPage} "${Datafile}"
	GiveWebPageKeywordTextEmailListFilethenNotify "${Bonktown}" "${Datafile}"


	BonktownTemp=`echo ${Bonktown}`
    fi
    
    ChainlovePage=$(GetPageReturnFile http://www.chainlove.com)
    Chainlove=$(GivePageReturnText ${ChainlovePage} )

    if [ "${Chainlove}" != "${ChainloveTemp}" ]
    then
	echo ${Chainlove}
#	GiveWebPageKeywordTextEmailListFilethenNotify ${ChainlovePage} "${Datafile}"
	GiveWebPageKeywordTextEmailListFilethenNotify "${Chainlove}" "${Datafile}"


	ChainloveTemp=`echo ${Chainlove}`
    fi
    SCTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${SteepAndCheapPage})
    WMTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${WhiskeyMilitiaPage})
    BTTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${BonktownPage})
    CLTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${ChainlovePage})

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

    SleepTimeMinutesSeconds=$(GiveSecondsReturnMinutesAndSeconds ${SleepTime})
    echo "Next deal at ${NextDeal} in ${SleepTimeMinutesSeconds} minutes from" `date +%T `
    sleep ${SleepTime}s
    TmpDiskSpaceStatus=$(checktmpdiskspace )
    HomeDiskSpaceStatus=$(checkhomediskspace )
    NetStatus=$(checknet )
done

if [ "$TmpDiskSpaceStatus" -ne 1 ]
then
    echo "Tmp disk space too low. Exiting"
fi
if [ "$HomeDiskSpaceStatus" -ne 1 ]
then
    echo "Home disk space too low. Exiting"
fi
if [ "$NetStatus" -ne 1 ]
then
    echo "The internet is unreachable. Exiting"
fi

#Add items up for sale to a database. it should include item, price, percent off,quantity,time duration of sale and date of deal- put in sqlite database
#have it ignore womens/mens items 
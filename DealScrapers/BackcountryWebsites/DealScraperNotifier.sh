#!/bin/bash

#This program scrapes the four deal websites and displays the current deal
#It will determines which site has the next upcoming deal and waits until
#that site has a new deal before updating.
#It appears that time isn't linear across all websites as 

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
#remove temporary files                                                             WebpageArray=( "/tmp/SteepAndCheapPage" "/tmp/WhiskeyMilitiaPage" "/tmp/BonktownPage" "/tmp/ChainlovePage" )
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
    Image='/tmp/ProductImage.jpg' #`mktemp`
    wget ${OutputText} -O ${Image} -q
    echo ${Image}
}

function GivePageReturnTotalQuantity()
{
    TotalQuantity=`grep total_qty_bar.set_data\( ${1} | sed 's/.*,//;s/[)].*//' `
    echo ${TotalQuantity}
}

function GiveSecondsReturnMinutesAndSeconds()
{
    input=${1}
#YOU WEREN"T QUOTING YOUR VARIABLE! THAT IS WHY THIS WAS FAILING
#    if [ ${input} == "\r" ] # \n check if null with -z ${input}
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


function GiveProductKeywordDatabaseTablethenNotify()
{
    Product=${1}
#    MySQLDatabase=${2}
 #   MySQLTableName=${3}
    ImageFile=${2}
    #echo "${ImageFile}"
    MySQLHost="mysql.server272.com"
    MySQLPort="3306"
    MySQLDatabase="djinnius_BackCountryAlerts"
    MySQLTableName="SearchTermsAndContactAddress"
    MySQLUser="BCA"
    MySQLPassword="backcountryalerts"
    mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="select * from ${MySQLTableName}" --silent --skip-column-names | while read databaserecords; do
#    sqlite3 ${Database} "select * from ${TableName}" | while read databaserecords; do
#	echo $databaserecords
	Array=($(echo "${databaserecords}" )) # the -s option for mysql suppresse the boxed output # this needed for sqlite3 --> | sed 's/|/ /g'))
	Primary_Key=${Array[0]}
	keyword=${Array[1]} #` cut -d "|" -f 1 `
	EmailTextAddress=${Array[2]} #cut -d "|" -f 1 `
	ImageAttachment=${Array[3]}
#I need a way to keep track if a certain product has been sent all ready to a specific address and check so I don't send duplicates out each time.
	if grep -q "${keyword}" <<<"${Product}"
	then
	    echo "We have a match for ${keyword}"
	    echo "Addr:${EmailTextAddress}"
	    SendNotice ${EmailTextAddress} "${Product}" $ImageAttachment "${ImageFile}"
#perl  sendEmail -f inkydinky@djinnius.com -t 5079909052@tmomail.net -u 'Subject line' -m 'Message Body' -s mail.djinnius.com:587 -xu user -xp password
	fi
    done
}

function SendNotice()
{
Address=${1}
Message=${2}
ImageAttachmentBoolean=${3}
ImageFile="${4}"

if [ ${ImageAttachmentBoolean} == "NULL" ]
then 
ImageAttachmentBoolean=0
fi
#echo "Addr:${Address} -Msg:${Message}"
if [ ${ImageAttachmentBoolean} -eq 0 ]
then
    perl /home/nicolae/Downloads/sendEmail-v1.56/sendEmail.pl -f deals@djinnius.com -t ${Address}  -m "${Message}" -s mail.djinnius.com:587 -xu deals -xp backcountry
else 
    perl /home/nicolae/Downloads/sendEmail-v1.56/sendEmail.pl -f deals@djinnius.com -t ${Address} -u 'A Matching Deal from BackCountry' -m "${Message}" -s mail.djinnius.com:587 -xu deals -xp backcountry -a "${ImageFile}"
fi
}

function GiveProductKeywordTextEmailListFilethenNotifyDEPRECATED()
{
    while read keyword phonenumber email
    do 
	if  grep -q "${keyword}" <<<${1}   # we use the -q since we just want the exit code
	then 
	    echo "We have a match at ${Match}"
	    echo "sending ${1} to ${phonenumber} and ${email}"
#    sendTexttoPhone "${1}" "$phonenumber" #quotes on phone not necessary...
#    sendEmail "${1}" "${email}"
# perl  sendEmail -f inkydinky@djinnius.com -t 5079909052@tmomail.net -u 'Subject line' -m 'Message Body' -s mail.djinnius.com:587 -xu user -xp password
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

#Datafile='Data.txt'

TmpDiskSpaceStatus=$( checktmpdiskspace )
HomeDiskSpaceStatus=$( checkhomediskspace )
NetStatus=$( checknet )
while [[ $TmpDiskSpaceStatus -eq 1 && $HomeDiskSpaceStatus -eq 1 && $NetStatus -eq 1 ]] ; do 
    SteepAndCheapPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.steepandcheap.com 0 )
    if [ "$SteepAndCheapPage" != "Error" ]
    then

	SteepAndCheap=$(GivePageReturnText ${SteepAndCheapPage} )
#if there are changes to the item description then we update and print the new info
	SCTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${SteepAndCheapPage})
	if [ "${SteepAndCheap}" != "${SteepAndCheapTemp}" ]
	then
	    echo ${SteepAndCheap} 
	    SteepAndCheapImage=$(GivePageAndWebsiteReturnImage ${SteepAndCheapPage} http://www.steepandcheap.com )
	    GiveProductKeywordDatabaseTablethenNotify ${SteepAndCheap} ${SteepAndCheapImage} 
	    SteepAndCheapTemp=`echo ${SteepAndCheap}`
	fi
    else
        echo "Wget didn't return a 200 OK response when getting the Steep and Cheap webpage"
        SCTimeLeftSeconds=120
    fi
    WhiskeyMilitiaPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.whiskeymilitia.com 1 )
    if [ "$WhiskeyMilitiaPage" != "Error" ]
    then
	WhiskeyMilitia=$(GivePageReturnText ${WhiskeyMilitiaPage} )

	WMTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${WhiskeyMilitiaPage})
	if [ "${WhiskeyMilitia}" != "${WhiskeyMilitiaTemp}" ]
	then
	    echo ${WhiskeyMilitia}
	    WhiskeyMilitiaImage=$(GivePageAndWebsiteReturnImage ${WhiskeyMilitiaPage} http://www.whiskeymilitia.com )
	    GiveProductKeywordDatabaseTablethenNotify  "${WhiskeyMilitia}"  ${WhiskeyMilitiaImage} 
	    WhiskeyMilitiaTemp=`echo ${WhiskeyMilitia}`
	fi
    else
        echo "Wget didn't return a 200 OK response when getting the Whiskey Mil\
itia webpage"
	WMTimeLeftSeconds=120
    fi
    BonktownPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.bonktown.com 2 )
    if [ "$BonktownPage" != "Error" ]
    then
	Bonktown=$(GivePageReturnText ${BonktownPage} )

	BTTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${BonktownPage})
	if [ "${Bonktown}" != "${BonktownTemp}" ]
	then
	    echo ${Bonktown}
BonktownImage=$(GivePageAndWebsiteReturnImage ${BonktownPage} http://www.bonktown.com )
	    GiveProductKeywordDatabaseTablethenNotify "${Bonktown}" ${BonktownImage} 
	    BonktownTemp=`echo ${Bonktown}`
	fi
    else
        echo "Wget didn't return a 200 OK response when getting the Bonktown we\
bpage"
        BTTimeLeftSeconds=120
    fi
    ChainlovePage=$(GiveWebsiteCodeGetWebpageTempFile http://www.chainlove.com 3 )
    if [ "$ChainlovePage" != "Error" ]
    then
	Chainlove=$(GivePageReturnText ${ChainlovePage} )
	CLTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${ChainlovePage})
	if [ "${Chainlove}" != "${ChainloveTemp}" ]
	then
	    echo ${Chainlove}
	    ChainloveImage=$(GivePageAndWebsiteReturnImage ${ChainlovePage} http://www.chainlove.com )
	    GiveProductKeywordDatabaseTablethenNotify "${Chainlove}" ${ChainloveImage} 
	    ChainloveTemp=`echo ${Chainlove}`
	fi
    else
        echo "Wget didn't return a 200 OK response when getting the Chainlove webpage"
        CLTimeLeftSeconds=120
    fi

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
#!/bin/bash

#This program scrapes the four deal websites and displays the current deal
#It will determines which site has the next upcoming deal and waits until
#that site has a new deal before updating.
#It appears that time isn't linear across all websites as 


#BASH programming caveats
#since there is no compiling I was having the program stop because I was trying to reference a variable that didn't exist bc I had spelled the name wrong.
#This just caused the program to stop dead in its tracks and not progress farther

#create table ProductImages( image_id serial, filename varchar(255) not null, number_of_times_seen int not null default 1, last_seen timestamp default current_timestamp on update current_timestamp,  primary key (image_id), index (filename));

function GetMimeType()
{
    file --mime-type "${1}" | sed 's/[^:]*: //'
}
function GetFileSize()
{
    du -k | awk '{print $1}'
}

function UploadFileToDjinniusDeals
{

    bash UploadFileToDjinniusDeals.sh "nM&^%4Yu" "${1}"
}


function checknet()
{
    flag=0
    if eval "ping -c 1 www.djinnius.com > /dev/null"; then
        echo "1"
    else
#if we don't have 'net cuz of sporadic wifi, recheck and sleep in between tries
        for num in 1 2 3 4 5 6
        do
            if eval "ping -c 1 www.djinnius.com > /dev/null"; then
                flag=1
                break
            else
                sleep 10s
            fi
        done
        echo ${flag}
    fi
#I was mistakenly echoing more than just one value and this was causing the subsequent checks on the returned values to barf.
}

function checkdiskspace()
{
    diskspacelimit=$2
    DiskSpace=$(df -h "${1}" | grep -v Filesystem | awk '{ print $4  }' )
    digits=$(df -h "${1}" | grep -v Filesystem | awk '{ print $4  }'| sed 's/.$//' )
    BytesLetter=$(df -h  "${1}" | grep -v Filesystem | awk '{ print $4  }'| sed 's/[0-9]//g' )

    Output=0    

    case $BytesLetter in
	"")
	    Output=0;; #no letter is displayed when there is 0 space left
	"K")
	    Output=0;; #assumes need more than a couple kilobytes :)
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
    WebpageArray=( "/tmp/SteepAndCheapPage" "/tmp/WhiskeyMilitiaPage" "/tmp/BonktownPage" "/tmp/ChainlovePage" )
    echo "Ok, caught Ctrl-c, exiting after clean up"
    for item in "${WebpageArray[@]}"
    do
	if [ -e ${item}  ]
	then 
	    rm ${item}
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

function GivePageReturnProductDescriptionV2()
{
#Version 2 removes the <title> html tags
#it appears that mysql doesn't care about the single quotes problem that sqlite has
    OutputText=`grep "<title>" ${1} |  sed -n 's/[^:]*://p' |sed 's/ - \$.*//;s/<title>//;s/<\/title>//' `
#Explanation: replace everything up to the colon that isn't a colon with nothing, print the rest
    echo ${OutputText}
}

function GivePageReturnPrice()
{
    OutputText=`grep "<title>" ${1} | sed 's/.*[\$]//' | sed 's/- .*//' `
    echo ${OutputText}
}

function GivePageReturnPercentOffMSRP()
{
    OutputText=`grep "<title>" ${1} |  sed 's/.* - //;s/%.*//' `
# or could use the tag stripping command of sed 's/<[^>]*>//g'
    echo ${OutputText}
}


function GiveProductProductImageEnterIntoDatabase()
{
#ok I can see the pros and cons of not storing the image in the db. 
#if I just store the images on teh server, the product name will serve as the image filename as well. Yet I can easily delete the image while still having a record in the db. but if I run the file delete command in conjunction with the db delete then we shouldn't have a problem.
    SentEmailTextAddressList=""
    SentEmailTextAddressList_arraycounter=0
    Product="${1}"
#    MySQLDatabase=${2}
 #   MySQLTableName=${3}
    ImageFile=${2}
    #echo "${ImageFile}"
    MySQLHost="mysql.server272.com"
    MySQLPort="3306"
    MySQLDatabase="djinnius_BackCountryAlerts"
    MySQLTableName="ProductImages"
    MySQLUser="BCA"
    MySQLPassword="backcountryalerts"
    flag=0

#check and see if the product all ready entered in database
    query="select image_id,filename,number_of_times_seen from ${MySQLTableName} where filename=\"${Product}\"" 
    query="select image_id,filename from ${MySQLTableName} where filename=\"${Product}\""  
#    query="select image_id,filename,number_of_times_seen from ProductImages where filename=\"Cutter Tall Boy Sock - 3-Pack\"" 
    #mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${query}" --silent --skip-column-names | while read databaserecords; do
    databaserecords=$(mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${query}" --silent --skip-column-names  )
    databaserecordsSize=${#databaserecords}
    if [ $databaserecordsSize -ne 0 ]
    then

# the database query was being piped straight into the while statement. this was causing ascope problem as piping utilizes a subshell so the 'flag' variable was out of scope when I needed it.
#also using the databasearecords isn't very useful because each field is hard to get (esp text) as spaces are treated as a field separator

#we SHOULD only get one record back otherwise this isn't working the way I want it to
	echo "Matching records primary_key:$databaserecords"
        Array=($(echo "${databaserecords}" )) 
        Primary_Key=${Array[0]}
	file="${Array[1]}"
#	echo "db:${file}-prod:${Product}"
	query="UPDATE ${MySQLTableName} SET number_of_times_seen=number_of_times_seen+1 where image_id=${Primary_Key}" 
	mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${query}" --silent
	flag=1
#	echo "flag inside:${flag}"
fi
#    done
 #   echo "flag outside:${flag}"
    if [ ${flag} -eq 0 ] #then we haven't inserted that data into the database yet
    then 
	echo "Match not found in database, entering in ${Product} as a new item"
	query="insert into  ${MySQLTableName} (filename) value (\"${Product}\")"
	#echo "${query}"
	mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${query}" --silent
#	Filename00=`echo "${Product}"| recode html`
#	Filename=$Filename00.jpg
	Filename=${Product}.jpg
	#echo ${Product} ${Filename}
	cp -T "${ImageFile}" "${Filename}"
	UploadFileToDjinniusDeals "${Filename}"
	rm "${Filename}"

    fi

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

#YOU WEREN"T QUOTING YOUR VARIABLE! THAT IS WHY THIS WAS FAILING
    if [ "${input}" == "" ] # \n check if null with -z ${input}
    then 
	echo "Null time"
	input=99999
    fi
    let "minutes = ${1} / 60"
    let "seconds = ${1} % 60 "
    printf "%d:%02d" ${minutes} ${seconds}

}
function GivePageReturnTotalQuantity()
{   
    TotalQuantity=`grep total_qty_bar.set_data\( ${1} | sed 's/.*,//' | sed 's/).*//' `
    echo ${TotalQuantity}
}
function GivePageReturnTimeRemainingInSeconds()
{
#two forms setupTimerBar or setupWMTimerBar
    TimeRemainingInSeconds=`grep "TimerBar" ${1} | sed 's/.*(//' | sed 's/,.*//'   `
#if the value somehow comes out negative then we'll just wait X more seconds and hit it again
    Quantity=$(GivePageReturnTotalQuantity ${1})
    Price=$(GivePageReturnPrice  ${1})
#since price is floating point value we need to use bc to perform the math comparison
#alternatively, since we don't require any great precision, we could use printf and only have the digits before the decimal point used.
    if [ $Quantity -lt 5 ] && [ $(echo "$Price < 300" | bc ) -eq 1 ] 
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
trap on_exit SIGINT
TmpDiskSpaceStatus=$( checktmpdiskspace )
HomeDiskSpaceStatus=$( checkhomediskspace )
NetStatus=$( checknet )
while [[ $TmpDiskSpaceStatus -eq 1 && $HomeDiskSpaceStatus -eq 1 && $NetStatus -eq 1 ]] ; do 
    SteepAndCheapPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.steepandcheap.com 0 )
    if [ "$SteepAndCheapPage" != "Error" ] 
    then 
#	SteepAndCheap=$(GivePageReturnText ${SteepAndCheapPage} )
	SteepAndCheap=$(GivePageReturnProductDescriptionV2 ${SteepAndCheapPage} )
#if there are changes to the item description then we update and print the new info
	if [ "${SteepAndCheap}" != "${SteepAndCheapTemp}" ]
	then
	    SCTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${SteepAndCheapPage})
	    echo ${SteepAndCheap} 
	    SteepAndCheapImage=$(GivePageAndWebsiteReturnImage ${SteepAndCheapPage} http://www.steepandcheap.com )

	    GiveProductProductImageEnterIntoDatabase "${SteepAndCheap}" "${SteepAndCheapImage}"


#copy content to our temp holder so we can see if things changed.
	    SteepAndCheapTemp=`echo ${SteepAndCheap}`
	fi
    else
	echo "Wget didn't return a 200 OK response when getting the Steep and Cheap webpage"
	SNCTimeLeftSeconds=120
    fi
    WhiskeyMilitiaPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.whiskeymilitia.com 1 )
    if [ "$WhiskeyMilitiaPage" != "Error" ]
    then 

#	WhiskeyMilitia=$(GivePageReturnText ${WhiskeyMilitiaPage} )
	WhiskeyMilitia=$(GivePageReturnProductDescriptionV2 ${WhiskeyMilitiaPage} )

	WMTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${WhiskeyMilitiaPage})

	if [ "${WhiskeyMilitia}" != "${WhiskeyMilitiaTemp}" ]
	then
	    echo ${WhiskeyMilitia}
	    WhiskeyMilitiaImage=$(GivePageAndWebsiteReturnImage ${WhiskeyMilitiaPage} http://www.whiskeymilitia.com )
	    GiveProductProductImageEnterIntoDatabase "${WhiskeyMilitia}" "${WhiskeyMilitiaImage}"
	    WhiskeyMilitiaTemp=`echo ${WhiskeyMilitia}`
	fi
    else
	echo "Wget didn't return a 200 OK response when getting the Whiskey Militia webpage"
	WMTimeLeftSeconds=120
    fi

    BonktownPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.bonktown.com 2 )
    if [ "$BonktownPage" != "Error" ]
    then 
#	Bonktown=$(GivePageReturnText ${BonktownPage} )
	Bonktown=$(GivePageReturnProductDescriptionV2  ${BonktownPage} )
	BTTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${BonktownPage})

	if [ "${Bonktown}" != "${BonktownTemp}" ]
	then
	    echo ${Bonktown}
	    BonktownImage=$(GivePageAndWebsiteReturnImage ${BonktownPage} http://www.bonktown.com )
	    GiveProductProductImageEnterIntoDatabase "${Bonktown}" "${BonktownImage}"
	    BonktownTemp=`echo ${Bonktown}`
	fi
    else
	echo "Wget didn't return a 200 OK response when getting the Bonktown webpage"
	BTTimeLeftSeconds=120
    fi

    ChainlovePage=$(GiveWebsiteCodeGetWebpageTempFile http://www.chainlove.com 3 )
    if [ "$ChainlovePage" != "Error" ]  
    then 
#	Chainlove=$(GivePageReturnText ${ChainlovePage} )
	Chainlove=$(GivePageReturnProductDescriptionV2  ${ChainlovePage} )
	CLTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${ChainlovePage})
	if [ "${Chainlove}" != "${ChainloveTemp}" ]
	then
	    echo ${Chainlove}
	    ChainloveImage=$(GivePageAndWebsiteReturnImage ${ChainlovePage} http://www.chainlove.com )
	    GiveProductProductImageEnterIntoDatabase "${Chainlove}" "${ChainloveImage}"
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
    DealEndTime=$( GiveTimeInSecondsReturnDealEndTime ${SleepTime} )
    echo "Next deal at ${NextDeal} in ${SleepTimeMinutesSeconds} minutes from" `date +%T ` "which occurs at ${DealEndTime}"
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

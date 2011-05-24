#!/bin/bash

#This program scrapes the four deal websites and displays the current deal
#It will determines which site has the next upcoming deal and waits until
#that site has a new deal before updating.
#It appears that time isn't linear across all websites as 

#sqlite3 test.db "create table Backcountrydeals (Bkey INTEGER PRIMARY KEY, websiteCode int, product TEXT, price double, percentOffMSRP int, quantity int, dealdurationinminutes int, timeEnter DATE);"
#sqlite3 test.db "create table WebsiteCodes (WKey INTEGER PRIMARY KEY, website TEXT, websiteCode int);"
#sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('Steep and Cheap', 0);"
#sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('WhiskeyMilitia', 1);"
#sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('Bonktown', 2);"
#sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('Chainlove', 3);"


#sqlite3 test.db "insert into Backcountrydeals (websiteCode, product, price, quantity, dealdurationinminutes) values (0,'some test info', 12.99, 12, 25);"
#sqlite3 test.db "insert into Backcountrydeals (websiteCode, product, price, quantity, dealdurationinminutes) values (10,'A bike', 1320.99,2,25 );"



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

function GetPageReturnFile()
{
# DEPRECATED
#this function gets a webpage and echoes the name of the file that holds the desired text
    Webpage='/tmp/WebsitePage' #`mktemp`
    wget ${1} -O ${Webpage} -q
    echo ${Webpage}
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
#    wget ${1} -O ${Webpage} -q | grep "200 OK"
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
#    wget ${OutputText} -O ${Image} -q | grep "200 OK"
    wget ${OutputText} -O ${Image} 2>&1| grep -q "200 OK"
    WgetExitStatus=$?
    if [ $WgetExitStatus -eq 0 ]
    then
	echo ${Image}
    else
	echo "Error"
    fi
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
#    echo ${1}
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
    printf "%d:%02d" ${minutes} ${seconds}
#    if [ ${seconds} -lt 10 ];
#    then 
#	echo ${minutes}:0${seconds}
#    else
#	echo ${minutes}:${seconds} 
#FML the seconds need to be padded with zeros--well I suppose this is one way to do it
 #   fi
}

#Input: webpage file
#output: extracts time remaining of the item for sale on the page
function GivePageReturnTimeRemainingInSeconds()
{
#two forms setupTimerBar or setupWMTimerBar
#    TimeRemainingInSeconds=`grep setupWMTimerBar ${1} | sed 's/.*(//' | sed 's/,.*//'   `
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

function GiveTimeInSecondsReturnDealEndTime()
{
#this was found here:http://www.askdavetaylor.com/date_math_in_linux_shell_script.html about 2/3 of the way down you'll see a post by marcus that is where it came from                                                                                                                                                  
    NumDaysAdjust=0
    Output=`date --date @$(($(date +%s)-(3600*24*${NumDaysAdjust})+${1} )) +%T`
    echo ${Output}
}


function GiveTimeReturnDealEndTime()
{
    echo "Emptyfornow"
}

function GiveDatabaseTableWebPageWebsiteCodeEnterDataIntoDatabase()
{
    Database=${1}
    Table=${2}
    Webpage=${3}
    WebsiteCode=${4}
#enter data into database
    ProductDescription=$(GivePageReturnProductDescription ${Webpage} ) #3} )
    Price=$(GivePageReturnPrice ${Webpage} ) #3} )
    PercentOffMSRP=$(GivePageReturnPercentOffMSRP ${Webpage} ) #3} )
    TotalQuantity=$(GivePageReturnTotalQuantity ${Webpage} ) #3} )
    DurationInMinutes=$(GivePageReturnDurationOfDealInMinutes ${Webpage} ) #3} )
#echo "Duration:-${DurationInMinutes}-"
#echo ${ProductDescription} ${Price} ${PercentOffMSRP} ${TotalQuantity} ${DurationInMinutes}
    PreviousProduct=$( GiveDatabaseTableNameWebsiteCodeGetLastProductEntryFromDatabase  ${Database} ${Table} ${WebsiteCode} )
    PreviousTimeEnter=$( GiveDatabaseTableNameWebsiteCodeGetLastTimeEnterEntryFromDatabase  ${Database} ${Table} ${WebsiteCode} )
    PreviousDealDurationInMinutes=$( GiveDatabaseTableNameWebsiteCodeGetLastDealDurationInMinutesEntryFromDatabase  ${Database} ${Table} ${WebsiteCode} )
    PreviousProductDescription=${PreviousProduct/\'/\'\'} #\x27/\x27\x27}"
#echo "-" "${PreviousProduct}" "-" "${ProductDescription}" "-" "${PreviousProductDescription}" "-"

#We need to compare to the variable with the double single quotes since that is how we need to enter the string into the database
    if [ "${PreviousProductDescription}" != "${ProductDescription}" ]
    then
	echo "Entering new product info into database."
	GiveDatabaseTablenameDataEnterIntoDatabase  ${Database} ${Table} ${WebsiteCode} "${ProductDescription}" ${Price} ${PercentOffMSRP} ${TotalQuantity} ${DurationInMinutes}
    else
#prevent duplicate entries sequentially but allow duplicates if a certain period has passed therefore giving a check saying that we are pretty sure that this is just a repeat that day/week/whatever
#	CompareDateToNow "$PreviousTimeEnter" ${PreviousDealDurationInMinutes} 
	#echo "PrevDealDura" ${PreviousDealDurationInMinutes}
	TimeComparison=$( CompareDateToNow "$PreviousTimeEnter" ${PreviousDealDurationInMinutes} )
	One=1
#	echo "TiemComp" ${TimeComparison} " one"${One}
	if [ "$TimeComparison" -eq "$One" ] 
	then 
	    echo "Entering new product info into database."
	    GiveDatabaseTablenameDataEnterIntoDatabase  ${Database} ${Table} ${WebsiteCode} "${ProductDescription}" ${Price} ${PercentOffMSRP} ${TotalQuantity} ${DurationInMinutes}
	else
	    echo "Product the same, but time difference too little from previous entry."
	fi

	
    fi

}

function CompareDateToNow
{
#The problem I was having was that i was comparing utc time from the db to local time, i needed to compare utc to utc times.

#I wish I could use this: but I'm not sure how my fake calculation method would work
    DateToCompare="${1}"
#echo "toCompare:" "${DateToCompare}" "Date:" `date --utc +%F' '%T`
    MinuteThreshold=${2}
#we'll use the TC suffix to mean ToCompare
    YearTC="${DateToCompare:0:4}" #don't leave a space btw the = and " or I won't work
#echo "YearTC:" ${YearTC}
    MonthTC="${DateToCompare:5:2}" 
    DayTC="${DateToCompare:8:2}" 
    HourTC="${DateToCompare:11:2}" 
    MinutesTC="${DateToCompare:14:2}" 
    SecondsTC="${DateToCompare:17:2}" 
#echo  ${YearTC} ${MonthTC} ${DayTC} ${HourTC} ${MinutesTC} ${SecondsTC} "${DateToCompare}"
    YearTCSeconds=$(( 365*24*60*60*($YearTC-1970) ))
#`expr 365*24*60*60*($YearTC-1970) ` #this is supposed to work but didn't. maybe I'm donig something wrong
# we add the 10# infront of the variable to force the base to be decimal instead of octal (since we might get times that are 08 and then eprform math on them.  This will cause and error of "value too great for base (error token is "09")" or "08" this is because in octal 07 is the highest it can go.
    MonthTCSeconds=$(( 10#$MonthTC*31*24*60*60 ))  #`expr $MonthTC*31*24*60*60`
    DayTCSeconds=$(( 10#$DayTC*24*60*60 ))
    HourTCSeconds=$(( 10#$HourTC*60*60 ))
    MinutesTCSeconds=$(( 10#$MinutesTC*60  ))
    SecondsTCTotalSince1970=$(( $YearTCSeconds+$MonthTCSeconds+$DayTCSeconds+$HourTCSeconds+$MinutesTCSeconds+10#$SecondsTC ))
#echo $SecondsTCTotalSince1970
    Year=$( date --utc +%Y )
    Month=$( date --utc +%m )
    Day=$( date --utc +%d )
    Hour=$( date --utc +%H )
    Minute=$( date --utc +%M )
    Second=$( date --utc +%S )
    SecondsTotalSince1970=$(( (10#${Year}-1970)*365*24*60*60+10#${Month}*31*24*60*60+10#${Day}*24*60*60+10#${Hour}*60*60+10#${Minute}*60+10#${Second} ))
#echo $SecondsTCTotalSince1970 $SecondsTotalSince1970
#echo "SecsTC" $SecondsTCTotalSince1970 "SecsTotal" $SecondsTotalSince1970
    SecondsBetweenTimes=$(( $SecondsTotalSince1970-$SecondsTCTotalSince1970 ))
    Threshold=$(( ${MinuteThreshold}*60 ))
 #   echo "SEcsbtwTimes" $SecondsBetweenTimes "Thresh" $Threshold
    if  [ "$SecondsBetweenTimes" -lt "$Threshold" ] 
    then 
#We don't want to add the item into the database bc the product names are the same and the time difference isn't enough
	echo "0"
    else
#the time difference iis enough that we want to enter the item into the database even if the product names are the same.
	echo "1"
    fi

}

function GiveDatabaseTableNameWebsiteCodeGetLastDealDurationInMinutesEntryFromDatabase
{
    Database=${1}
    TableName=${2}
    WebsiteCode=$3
#echo $Database $TableName $WebsiteCode
    Query="select dealdurationinminutes from ${TableName} where websitecode=${WebsiteCode} order by Bkey desc limit 1"
    sqlite3 ${Database} "${Query}"
}

function GiveDatabaseTableNameWebsiteCodeGetLastProductEntryFromDatabase
{

    Database=${1}
    TableName=${2}
    WebsiteCode=$3
#echo $Database $TableName $WebsiteCode
    Query="select product from ${TableName} where websitecode=${WebsiteCode} order by Bkey desc limit 1"
    sqlite3 ${Database} "${Query}"
}

function GiveDatabaseTableNameWebsiteCodeGetLastTimeEnterEntryFromDatabase
{

    Database=${1}
    TableName=${2}
    WebsiteCode=$3
#echo $Database $TableName $WebsiteCode
    Query="select timeEnter from ${TableName} where websitecode=${WebsiteCode} order by Bkey desc limit 1"
    sqlite3 ${Database} "${Query}"
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
#check that the database exists and create if it doesn't
if [ !  -e  "test.db"  ]
then
    echo "database nonexistent, creating"
    sqlite3 test.db "create table Backcountrydeals (Bkey INTEGER PRIMARY KEY, websiteCode int, product TEXT, price double, percentOffMSRP int, quantity int, dealdurationinminutes int, timeEnter DATE);"
    sqlite3 test.db "create table WebsiteCodes (WKey INTEGER PRIMARY KEY, website TEXT, websiteCode int);"
    sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('Steep and Cheap', 0);"
    sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('WhiskeyMilitia', 1);"
    sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('Bonktown', 2);"
    sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('Chainlove', 3);"
#enter some fake data
#sqlite3 test.db "insert into Backcountrydeals (websiteCode, product, price, quantity, dealdurationinminutes) values (0,'some test info', 12.99, 12, 25);"
#sqlite3 test.db "insert into Backcountrydeals (websiteCode, product, price, quantity, dealdurationinminutes) values (10,'A bike', 1320.99,2,25 );"

fi
TmpDiskSpaceStatus=$( checktmpdiskspace )
HomeDiskSpaceStatus=$( checkhomediskspace )
NetStatus=$( checknet )
while [[ $TmpDiskSpaceStatus -eq 1 && $HomeDiskSpaceStatus -eq 1 && $NetStatus -eq 1 ]] ; do 
    #SteepAndCheapPage=$(GetPageReturnFile http://www.steepandcheap.com)
    SteepAndCheapPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.steepandcheap.com 0 )
    if [ "$SteepAndCheapPage" != "Error" ] 
    then 
	SteepAndCheap=$(GivePageReturnText ${SteepAndCheapPage} )

#if there are changes to the item description then we update and print the new info
	if [ "${SteepAndCheap}" != "${SteepAndCheapTemp}" ]
	then
	    SCTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${SteepAndCheapPage})
	    echo ${SteepAndCheap} 

	    GiveDatabaseTableWebPageWebsiteCodeEnterDataIntoDatabase "test.db" "Backcountrydeals" ${SteepAndCheapPage} 0
#GiveDatabaseTablenameDataEnterIntoDatabase  test.db Backcountrydeals 0 $ProductDescription bob=$(GivePageReturnProductDescription ${SteepAndCheapPage})  (GivePageReturnPrice ${SteepAndCheapPage}) (GivePageReturnPercentOffMSRP ${SteepAndCheapPage}) (GivePageReturnTotalQuantity ${SteepAndCheapPage}) (GivePageReturnDurationOfDealInMinutes ${SteepAndCheapPage}) 
#GiveDatabaseTablenameDataEnterIntoDatabase  test.db Backcountrydeals 0 (GivePageReturnProductDescription ${SteepAndCheapPage})  (GivePageReturnPrice ${SteepAndCheapPage}) (GivePageReturnPercentOffMSRP ${SteepAndCheapPage}) (GivePageReturnTotalQuantity ${SteepAndCheapPage}) (GivePageReturnDurationOfDealInMinutes ${SteepAndCheapPage}) 
#	Null=$(GiveDatabaseTablenameDataEnterIntoDatabase  test.db Backcountrydeals 0 GivePageReturnProductDescription ${SteepAndCheapPage} GivePageReturnPrice ${SteepAndCheapPage} GivePageReturnPercentOffMSRP ${SteepAndCheapPage} GivePageReturnTotalQuantity ${SteepAndCheapPage} GivePageReturnDurationOfDealInMinutes ${SteepAndCheapPage} )
#sqlite3 ${1} "insert into ${2} (websiteCode, product, price, percentOffMSRP, quantity, dealdurationinminutes) values (${3}, ${4}, ${5}, ${6},${7}, ${8} );"
#copy content to our temp holder so we can see if things changed.
	    SteepAndCheapTemp=`echo ${SteepAndCheap}`
	fi
    else
	echo "Wget didn't return a 200 OK response when getting the Steep and Cheap webpage"
	TimeLeftSeconds=120
    fi
#    WhiskeyMilitiaPage=$(GetPageReturnFile http://www.whiskeymilitia.com)
    WhiskeyMilitiaPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.whiskeymilitia.com 1 )
    if [ "$WhiskeyMilitiaPage" != "Error" ]
    then 
	WhiskeyMilitia=$(GivePageReturnText ${WhiskeyMilitiaPage} )
	WMTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${WhiskeyMilitiaPage})

	if [ "${WhiskeyMilitia}" != "${WhiskeyMilitiaTemp}" ]
	then
	    echo ${WhiskeyMilitia}
	    GiveDatabaseTableWebPageWebsiteCodeEnterDataIntoDatabase "test.db" "Backcountrydeals"  ${WhiskeyMilitiaPage} 1
	    WhiskeyMilitiaTemp=`echo ${WhiskeyMilitia}`
	fi
    else
	echo "Wget didn't return a 200 OK response when getting the Whiskey Militia webpage"
	WMTimeLeftSeconds=120
    fi

#    BonktownPage=$(GetPageReturnFile http://www.bonktown.com)
    BonktownPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.bonktown.com 2 )
    if [ "$BonktownPage" != "Error" ]
    then 
	Bonktown=$(GivePageReturnText ${BonktownPage} )
	BTTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${BonktownPage})

	if [ "${Bonktown}" != "${BonktownTemp}" ]
	then
	    echo ${Bonktown}
	    GiveDatabaseTableWebPageWebsiteCodeEnterDataIntoDatabase test.db "Backcountrydeals"  ${BonktownPage} 2
	    BonktownTemp=`echo ${Bonktown}`
	fi
    else
	echo "Wget didn't return a 200 OK response when getting the Bonktown webpage"
	BTTimeLeftSeconds=120
    fi
    
#    ChainlovePage=$(GetPageReturnFile http://www.chainlove.com)
    ChainlovePage=$(GiveWebsiteCodeGetWebpageTempFile http://www.chainlove.com 3 )
    if [ "$ChainlovePage" != "Error" ]  
    then 
	Chainlove=$(GivePageReturnText ${ChainlovePage} )
	CLTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${ChainlovePage})
	if [ "${Chainlove}" != "${ChainloveTemp}" ]
	then
	    echo ${Chainlove}
	    GiveDatabaseTableWebPageWebsiteCodeEnterDataIntoDatabase test.db Backcountrydeals  ${ChainlovePage} 3
	    ChainloveTemp=`echo ${Chainlove}`
	fi
    else
	echo "Wget didn't return a 200 OK response when getting the Chainlove webpage"
	CLTimeLeftSeconds=120
    fi
 #   echo $SCTimeLeftSeconds $WMTimeLeftSeconds $BTTimeLeftSeconds $CLTimeLeftSeconds
#for some reason it appears that the XXXXPage was going out of scope and we were only using the last page seen..i.e. ChainlovePage for all the functions here. NO it was the reuse of the /tmp/Webpage that was screwing things up.
#    SCTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${SteepAndCheapPage})
#    echo $SCTimeLeftSeconds 
#    WMTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds "${WhiskeyMilitiaPage}")
#    echo $WMTimeLeftSeconds 
 #   BTTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${BonktownPage})
#    echo $BTTimeLeftSeconds 
  #  CLTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${ChainlovePage})
#    echo $SCTimeLeftSeconds $WMTimeLeftSeconds $BTTimeLeftSeconds $CLTimeLeftSeconds
    #I had been making a logic error here for quite some time.
#I didn't understand why sometimes the "math" would be off and a smaller value wouldn't be assigned to the SleepTime
#It was due to me using a if.then.elif.then.elif.then cascade. I was
#mistakenly thinking that this was the correct method to get the smallest value
#into SleepTime. This was wrong because if WMTimeLeftSeconds was smaller than 
#the one for SnC then it would be assigned to SLeepTime and it would kick out of the loop. As long as ONE of the conditions held it'd kick out and not go futher and evaluate any more of the logic tests. DUH. yet this took me a while to figure out.
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

#Add items up for sale to a database. it should include item, price, percent off,quantity,time duration of sale and date of deal- put in sqlite database
#have it ignore womens/mens items 
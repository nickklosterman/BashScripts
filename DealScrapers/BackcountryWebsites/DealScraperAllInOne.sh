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

    bash UploadFileToDjinniusDeals.sh "nM&^%4Yu" "${1}" &
}

function UploadImageFileToDjinniusDeals
{
#Duh it only uploads when an item is new!
    echo "Uploading ${1} to ProductImages"
    bash UploadFileToDjinniusDealsImages.sh "nM&^%4Yu" "${1}" #awww fuck.  I was backgrounding this and the file was being deleted before it was uploaded. that's why I was getting the error!
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
#----BEGIN - FUNCTIONS SPECIFIC TO PRODUCT DATABASE ------
function CompareDateToNow
{
#The problem I was having was that i was comparing utc time from the db to local time, i needed to compare utc to utc times.                                
    DateToCompare="${1}"
    MinuteThreshold=${2}
#we'll use the TC suffix to mean ToCompare                                                                                                                  
    YearTC="${DateToCompare:0:4}" #don't leave a space btw the = and " or I won't work                                                                      
    MonthTC="${DateToCompare:5:2}"
    DayTC="${DateToCompare:8:2}"
    HourTC="${DateToCompare:11:2}"
    MinutesTC="${DateToCompare:14:2}"
    SecondsTC="${DateToCompare:17:2}"
    YearTCSeconds=$(( 365*24*60*60*($YearTC-1970) ))
#`expr 365*24*60*60*($YearTC-1970) ` #this is supposed to work but didn't. maybe I'm donig something wrong                                                  
# we add the 10# infront of the variable to force the base to be decimal instead of octal (since we might get times that are 08 and then eprform math on the\m.  This will cause and error of "value too great for base (error token is "09")" or "08" this is because in octal 07 is the highest it can go.    MonthTCSeconds=$(( 10#$MonthTC*31*24*60*60 ))  #`expr $MonthTC*31*24*60*60`                                                                             
    DayTCSeconds=$(( 10#$DayTC*24*60*60 ))
    HourTCSeconds=$(( 10#$HourTC*60*60 ))
    MinutesTCSeconds=$(( 10#$MinutesTC*60  ))
    SecondsTCTotalSince1970=$(( $YearTCSeconds+$MonthTCSeconds+$DayTCSeconds+$HourTCSeconds+$MinutesTCSeconds+10#$SecondsTC ))

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

# if you keep getting an error it is because MinuteThreshold is empty bc the entry into the database was corrupted. Run the cleanup script
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

GiveDatabaseTablenameDataEnterIntoDatabase()
{
    sqlite3 ${1} "insert into ${2} (websiteCode, product, price, percentOffMSRP, quantity, dealdurationinminutes) values ( '${3}', '${4}', '${5}', '${6}', '${7}', '${8}' );"
}
function GiveDatabaseTableWebPageWebsiteCodeEnterDataIntoDatabase()
{
    Database=${1}
    Table=${2}
    Webpage=${3}
    WebsiteCode=${4}
#enter data into database                                                                                                                                    
    ProductDescription=$(GivePageReturnProductDescription ${Webpage} )
    Price=$(GivePageReturnPrice ${Webpage} )
    PercentOffMSRP=$(GivePageReturnPercentOffMSRP ${Webpage} )
    TotalQuantity=$(GivePageReturnTotalQuantity ${Webpage} )
    if [ "${TotalQuantity}" == "" ]
    then
	echo "Total Quantity is empty!!! ${WebsiteCode}"
    fi
    DurationInMinutes=$(GivePageReturnDurationOfDealInMinutes ${Webpage} )
    PreviousProduct=$( GiveDatabaseTableNameWebsiteCodeGetLastProductEntryFromDatabase  ${Database} ${Table} ${WebsiteCode} )

    PreviousTimeEnter=$( GiveDatabaseTableNameWebsiteCodeGetLastTimeEnterEntryFromDatabase  ${Database} ${Table} ${WebsiteCode} )
    PreviousDealDurationInMinutes=$( GiveDatabaseTableNameWebsiteCodeGetLastDealDurationInMinutesEntryFromDatabase  ${Database} ${Table} ${WebsiteCode} )
    PreviousProductDescription=${PreviousProduct/\'/\'\'} #this doubles the single quotes for entry into the sqlite database
    echo "prev_time_enter:$PreviousTimeEnter: prev_deal_duration:$PreviousDealDurationInMinutes:" 
#We need to compare to the variable with the double single quotes since that is how we need to enter the string into the database                           
    if [ "${PreviousProductDescription}" != "${ProductDescription}" ]
    then
        echo "Entering new product info into database."
        GiveDatabaseTablenameDataEnterIntoDatabase  ${Database} ${Table} ${WebsiteCode} "${ProductDescription}" ${Price} ${PercentOffMSRP} ${TotalQuantity} ${DurationInMinutes}
    else
#prevent duplicate entries sequentially but allow duplicates if a certain period has passed therefore giving a check saying that we are pretty sure that this is just a repeat that day/week/whatever
# if you keep getting an error it is because PreviousDealDurationInMinutes is empty bc the entry into the database was corrupted. Run the cleanup script
	TimeComparison=$( CompareDateToNow "${PreviousTimeEnter}" ${PreviousDealDurationInMinutes} )
        	
        if [ "$TimeComparison" -eq 1 ] # "${ProductDescription}" != "" ${Price} != ""  ${PercentOffMSRP} != ""  ${TotalQuantity}!= ""  ${DurationInMinutes} != ""
        then
            echo "Entering new product info into database."
	    echo "TODO : WE NEED TO TYPECHECK THAT WE ARE ENTERING VALID DATA HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            GiveDatabaseTablenameDataEnterIntoDatabase  ${Database} ${Table} ${WebsiteCode} "${ProductDescription}" ${Price} ${PercentOffMSRP} ${TotalQuantity} ${DurationInMinutes}
        else
            echo "Product the same, but time difference too little from previous entry."
        fi
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
#----END - FUNCTIONS SPECIFIC TO PRODUCT DATABASE ------

#----BEGIN - FUNCTIONS SPECIFIC TO NOTIFIER ------
function GiveProductKeywordDatabaseTablethenNotify()
{
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
    MySQLTableName="SearchTermsAndContactAddress"
    MySQLUser="BCA"
    MySQLPassword="backcountryalerts"
    mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="select * from ${MySQLTableName}" --silent --skip-column-names | while read databaserecords; do

        Array=($(echo "${databaserecords}" )) 
        Primary_Key=${Array[0]}
        keyword="${Array[1]}" 
        EmailTextAddress=${Array[2]} 
        ImageAttachment=${Array[3]}
        AddressLength=${#EmailTextAddress}
#prevent problems associated with addr snuck in that are blank or too short to be real                                                              
        if [ $AddressLength -gt 4 ]
        then
#if we have a match then send message                                                                                                    
            if grep -q "${keyword}" <<<"${Product}"
            then
                echo "We have a match for ${keyword} w prim_key:$Primary_Key"

#Check if we all ready sent a message based on this keyword to this addr                                                                          
#pack array so we can pass it to the function                                                                                                     
                PackedAddressList=`echo ${SentEmailTextAddressList[@]}`
                MessageAllReadySent=$( CheckMessageSenttoAddressList "${PackedAddressList}" "${EmailTextAddress}" )
                if [ $MessageAllReadySent -eq 0 ]
                then
		    echo "Addr:${EmailTextAddress} Product:${Product}"
                    SendNotice ${EmailTextAddress} "${Product}" $ImageAttachment "${ImageFile}"
                else
                    echo "Skipping because message all ready sent to $EmailTextAddress"
                fi
                SentEmailTextAddressList[$SentEmailTextAddressList_arraycounter]=${EmailTextAddress}
                let "SentEmailTextAddressList_arraycounter+=1"
#Add address to our list to prevent mutliple emails being sent                                                                                              
#perl  sendEmail -f inkydinky@djinnius.com -t 5079909052@tmomail.net -u 'Subject line' -m 'Message Body' -s mail.djinnius.com:587 -xu user -xp password     
            fi
        fi
    done 
}

function CheckMessageSenttoAddressList()
{
#Check AddressList (a list of addresses the alert has all ready been sent to) for Address                                                                   
    AddressList=$1
    Address=$2
#get number of array elements                                                                                                                               
    ArrayElements=${#AddressList[@]}
    index=0
    flag=0
    while [ $index -lt $ArrayElements ]
    do
        if grep -q $Address <<< "${AddressList[$index]}"
        then
            flag=1
#if we found a match we can break                                                                                                                           
            break
        fi
        let "index = $index + 1"
    done
    echo ${flag}
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
    echo "Addr:${Address} -Msg:${Message}"
#Branch on whether or not to send image as attachment                                                                                                       
    if [ ${ImageAttachmentBoolean} -eq 0 ]
    then
	perl /home/nicolae/Downloads/sendEmail-v1.56/sendEmail.pl -f deals@djinnius.com -t ${Address}  -m "${Message}" -s mail.djinnius.com:587 -xu deals -xp backcountry
    else
        perl /home/nicolae/Downloads/sendEmail-v1.56/sendEmail.pl -f deals@djinnius.com -t ${Address} -u 'A Matching Deal from BackCountry' -m "${Message}" -s mail.djinnius.com:587 -xu deals -xp backcountry -a "${ImageFile}"
    fi
}


#----END - FUNCTIONS SPECIFIC TO NOTIFIER ------

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
function GivePageReturnProductDescription()
{
#for the possessive form I need to replace the single quote with double single quotes                                                                       
    OutputText=`grep "<title>" ${1} |  sed -n 's/[^:]*://p' | sed 's/ - \$.*//;s/\x27/\x27\x27/g' ` #this was causing problems with descriptions that had mltiple instances of the colon i.e. there was a colon in the description that caused the front part  of the description to be cut off.                        
#Explanation: replace everything up to the colon that isn't a colon with nothing, print the rest                                                            
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


function ConvertForwardSlashToBackSlash()
{
#the apostrophe for possessives screws things up so we need to convert it and then convert it back
Output=` echo "${1}" | tr '/' '\' `
#tried it without inclucing in backticks adn we got the entire webpages leaking in somehow instead of just the description text
# echo "${1}" | sed 's/\x27/\^/g; s/\//\\/g; s/\^/\x27/g' 
#stuff="mi/ke's"; echo ${stuff} | sed 's/\x27/\^/;s/\//\\/;s/\^/\x27/' # this works so what is up with the line above? ....uggggh cuz we weren't copying it over to the directory where we were executing the script!!!...but it still didn't work
echo "${Output}"
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
#TODO: make sure only 1 record is beign returned by creating a query that will erturn more than one results
#TODO: this dbase entry mechanism can update if we restart the script and give a time that is 'off' by at most the deal duration time. ie. instead of having the last seen time being when we initially see the deal it could be anytime in the deal duration period which isn't a big deal bc initially upon startup this will be the fact as well
	echo "Matching records primary_key:$databaserecords"
        Array=($(echo "${databaserecords}" )) 
        Primary_Key=${Array[0]}
#	file="${Array[1]}"
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

#	echo "beforeslash $Product"
	Filename=$( ConvertForwardSlashToBackSlash "${Product}").jpg #this takes care of the only forbidden character for filenames the '/' since that is interpreted as a directory separator
#	Filename=${Product}.jpg

#	echo "slash converted filename:${Filename2}: unconverted:${Filename}:"	
	#echo "afterslash $Filename"
	#echo "prod:${Product}: filename:${Filename}:"
#	echo "do we need to check and see if ImageFile exists first?"
	if [ -f "${ImageFile}"  ]
	then
	    cp -T "${ImageFile}" "${Filename}"
	    if [ -f "${Filename}" ]
	    then 
#		echo "filename exists, otherwise rm would bitch "
		UploadImageFileToDjinniusDeals "${Filename}"
		rm "${Filename}"
	    else 
		echo "filename:${Filename}: no existo"
	    fi
	    
	else
	    echo "Umm ${ImageFile} doesn't exist to copy!!"
	fi
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

function UpdateWebpage
{   
    WebsiteCode=${1}
    ProductDescription="${2}"
    Webpage="${4}"  #this is just the file that we are updating...ie. index.html
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

function UpdateWebpageMetaRefresh()
{   
    RefreshTime=${1}
    Webpage="${2}"
    output="<META HTTP-EQUIV=\"REFRESH\" CONTENT=\"${RefreshTime}\">"
    BeginLineNumber=$( GetTagLineNumber "\"Refresh Begin"\" "${Webpage}" )
    EndLineNumber=$( GetTagLineNumber "\"Refresh End"\" "${Webpage}" )
#echo $output $BeginLineNumber $EndLineNumber
    Top=$( GetBeginningOfFileToLine ${BeginLineNumber} "${Webpage}" )
    Bottom=$( GetLineToEOF ${EndLineNumber} "${Webpage}" )


    Output="${Top}
 ${output}
${Bottom}"

    echo "${Output}" > "${Webpage}"

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
    #echo "Webpage" "${1}"
    NumberOfRecordsToDisplay="${2}"
    BeginTag="${3}"
    EndTag="${4}"
    DatabaseName="${5}"
    BeginLineNumber=$( GetTagLineNumber "${BeginTag}" "${Webpage}" )
    EndLineNumber=$( GetTagLineNumber "${EndTag}" "${Webpage}" )
    #echo $BeginLineNumber $EndLineNumber

    Top=$( GetBeginningOfFileToLine ${BeginLineNumber} "${Webpage}" )

    Bottom=$( GetLineToEOF ${EndLineNumber} "${Webpage}" )

    QueryResults=$( GetQueryResults "${DatabaseName}" ${WebsiteCode} ${NumberOfRecordsToDisplay} )


#You need the extra empty lines otherwise the query results get put on our delimiter lines and that first result piles up and doesn't go away. it took me a while to figure out that this was happening.
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
    query="select product,price,percentOffMSRP,quantity,dealdurationinminutes,timeEnter from Backcountrydeals where websitecode=${WebsiteCode} order by Bkey desc limit ${NumberOfRecordsToDisplay}"
#for some reason it was having trouble expanding the quotes. To solve that i tried using eval but that seemed to not expand the variables so I had to do a two step approach.                                                                                        
    Output=`sqlite3 -html "${DatabaseName}" "${query}" `
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
WebpageIndex="/home/nicolae/Desktop/index.html" #maybe store it on the website in a template directory so its more universal?

trap on_exit SIGINT
TmpDiskSpaceStatus=$( checktmpdiskspace )
HomeDiskSpaceStatus=$( checkhomediskspace )
NetStatus=$( checknet )
while [[ $TmpDiskSpaceStatus -eq 1 && $HomeDiskSpaceStatus -eq 1 && $NetStatus -eq 1 ]] ; do 
    SteepAndCheapPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.steepandcheap.com 0 )
    if [ "$SteepAndCheapPage" != "Error" ] 
    then 
	SteepAndCheapText=$(GivePageReturnText ${SteepAndCheapPage} )
	SteepAndCheap=$(GivePageReturnProductDescriptionV2 ${SteepAndCheapPage} )
#if there are changes to the item description then we update and print the new info
	if [ "${SteepAndCheap}" != "${SteepAndCheapTemp}" ]
	then
	    SCTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${SteepAndCheapPage})
	    echo ${SteepAndCheap} 
	    SteepAndCheapImage=$(GivePageAndWebsiteReturnImage ${SteepAndCheapPage} http://www.steepandcheap.com )
	    GiveProductKeywordDatabaseTablethenNotify "${SteepAndCheapText}" ${SteepAndCheapImage}
	    GiveDatabaseTableWebPageWebsiteCodeEnterDataIntoDatabase "test.db" "Backcountrydeals" ${SteepAndCheapPage} 0
	    GiveProductProductImageEnterIntoDatabase "${SteepAndCheap}" "${SteepAndCheapImage}"
	    UpdateWebpage 0 "${SteepAndCheapText}" "${SteepAndCheapImage}"  "${WebpageIndex}"
            notify-send  "$SteepAndCheapText" -i ${SteepAndCheapImage} -t 3

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

	WhiskeyMilitiaText=$(GivePageReturnText ${WhiskeyMilitiaPage} )
	WhiskeyMilitia=$(GivePageReturnProductDescriptionV2 ${WhiskeyMilitiaPage} )

	WMTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${WhiskeyMilitiaPage})


	if [ "${WhiskeyMilitia}" != "${WhiskeyMilitiaTemp}" ]
	then
	    echo ${WhiskeyMilitia}
	    WhiskeyMilitiaImage=$(GivePageAndWebsiteReturnImage ${WhiskeyMilitiaPage} http://www.whiskeymilitia.com )
	    GiveProductKeywordDatabaseTablethenNotify  "${WhiskeyMilitiaText}"  ${WhiskeyMilitiaImage}
	    GiveDatabaseTableWebPageWebsiteCodeEnterDataIntoDatabase "test.db" "Backcountrydeals"  ${WhiskeyMilitiaPage} 1
	    GiveProductProductImageEnterIntoDatabase "${WhiskeyMilitia}" "${WhiskeyMilitiaImage}"
	    UpdateWebpage 1 "${WhiskeyMilitiaText}" "${WhiskeyMilitiaImage}"   "${WebpageIndex}"
            notify-send  "$WhiskeyMilitiaText" -i ${WhiskeyMilitiaImage} -t 3

	    WhiskeyMilitiaTemp=`echo ${WhiskeyMilitia}`
	fi
    else
	echo "Wget didn't return a 200 OK response when getting the Whiskey Militia webpage"
	WMTimeLeftSeconds=120
    fi

    BonktownPage=$(GiveWebsiteCodeGetWebpageTempFile http://www.bonktown.com 2 )
    if [ "$BonktownPage" != "Error" ]
    then 
	BonktownText=$(GivePageReturnText ${BonktownPage} )
	Bonktown=$(GivePageReturnProductDescriptionV2  ${BonktownPage} )
	BTTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${BonktownPage})

	if [ "${Bonktown}" != "${BonktownTemp}" ]
	then
	    echo ${Bonktown}
	    BonktownImage=$(GivePageAndWebsiteReturnImage ${BonktownPage} http://www.bonktown.com )
	    GiveProductKeywordDatabaseTablethenNotify "${BonktownText}" ${BonktownImage}
	    GiveDatabaseTableWebPageWebsiteCodeEnterDataIntoDatabase test.db "Backcountrydeals"  ${BonktownPage} 2
	    GiveProductProductImageEnterIntoDatabase "${Bonktown}" "${BonktownImage}"
	    UpdateWebpage 2 "${BonktownText}" "${BonktownImage}"  "${WebpageIndex}"
            notify-send  "$BonktownText" -i ${BonktownImage} -t 3

	    BonktownTemp=`echo ${Bonktown}`
	fi
    else
	echo "Wget didn't return a 200 OK response when getting the Bonktown webpage"
	BTTimeLeftSeconds=120
    fi

    ChainlovePage=$(GiveWebsiteCodeGetWebpageTempFile http://www.chainlove.com 3 )
    if [ "$ChainlovePage" != "Error" ]  
    then 
	ChainloveText=$(GivePageReturnText ${ChainlovePage} )
	Chainlove=$(GivePageReturnProductDescriptionV2  ${ChainlovePage} )
	CLTimeLeftSeconds=$(GivePageReturnTimeRemainingInSeconds ${ChainlovePage})
	if [ "${Chainlove}" != "${ChainloveTemp}" ]
	then
	    echo ${Chainlove}
	    ChainloveImage=$(GivePageAndWebsiteReturnImage ${ChainlovePage} http://www.chainlove.com )
	    GiveProductKeywordDatabaseTablethenNotify "${ChainloveText}" ${ChainloveImage}
	    GiveDatabaseTableWebPageWebsiteCodeEnterDataIntoDatabase test.db Backcountrydeals  ${ChainlovePage} 3
	    GiveProductProductImageEnterIntoDatabase "${Chainlove}" "${ChainloveImage}"
	    UpdateWebpage 3 "${ChainloveText}" "${ChainloveImage}" "${WebpageIndex}"
            notify-send  "$ChainloveText" -i ${ChainloveImage} -t 3
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

    MetaRefresh=15 # add a litle bit of buffer time
    let "MetaRefresh += SleepTime"
echo "Metarefreshtime: ${MetaRefresh}" 
    UpdateWebpageMetaRefresh ${MetaRefresh} "${WebpageIndex}"
#it'd be nice if we could print the time ticking down and then refresh with the new deals. use "print" maybe?

    SleepTimeMinutesSeconds=$(GiveSecondsReturnMinutesAndSeconds ${SleepTime})
    DealEndTime=$( GiveTimeInSecondsReturnDealEndTime ${SleepTime} )
    echo "Next deal at ${NextDeal} in ${SleepTimeMinutesSeconds} minutes from" `date +%T ` "which occurs at ${DealEndTime}"
#    echo "SnC:${SnCTimeLeftSeconds} (${SnCQuantityRemaining}/${SnCTotalQuantity})  WM:${WMTimeLeftSeconds} (${WMQuantityRemaining}/${WMTotalQuantity}) BT:${BTTimeLeftSeconds} (${BTQuantityRemaining}/${BTTotalQuantity}) CL:${CLTimeLeftSeconds} (${CLQuantityRemaining}/${CLTotalQuantity})"
    echo "SnC:${SCTimeLeftSeconds} WM:${WMTimeLeftSeconds}  BT:${BTTimeLeftSeconds}  CL:${CLTimeLeftSeconds} "
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

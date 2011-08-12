#!/bin/bash

function EnterProductDataIntoDatabase()
{
    MySQLHost="mysql.server272.com"
    MySQLPort="3306"
    MySQLDatabase="djinnius_BackCountryAlerts"
    MySQLTableName="Backcountrydeals"
    MySQLUser="BCA"
    MySQLPassword="backcountryalerts"
    query="insert into  ${MySQLTableName} (websiteCode, product, price, percentOffMSRP, quantity, dealdurationinminutes) values ( '${1}', '${2}','${3}', '${4}', '${5}', '${6}' );"
    queryresult=$( mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${query}"   )
    echo "${queryresult}"
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
    if [ "${PreviousProductDescription}" != "${ProductDescription}" ]
    then
        echo "Entering new product info into database. reason:products not the same"
	EnterProductDataIntoDatabase ${WebsiteCode} "${ProductDescription}" ${Price} ${PercentOffMSRP} ${TotalQuantity} ${DurationInMinutes}
        GiveDatabaseTablenameDataEnterIntoDatabase  ${Database} ${Table} ${WebsiteCode} "${ProductDescription}" ${Price} ${PercentOffMSRP} ${TotalQuantity} ${DurationInMinutes}
    else
#prevent duplicate entries sequentially but allow duplicates if a certain period has passed therefore giving a check saying that we are pretty sure that this is just a repeat that day/week/whatever
# if you keep getting an error it is because PreviousDealDurationInMinutes is empty bc the entry into the database was corrupted. Run the cleanup script
	echo "prev_time_enter:${PreviousTimeEnter}: prev_deal_dur:${PreviousDealDurationInMinutes}:";
	CompareDateToNow2 "${PreviousTimeEnter}" ${PreviousDealDurationInMinutes} 
	TimeComparison=$( CompareDateToNow "${PreviousTimeEnter}" ${PreviousDealDurationInMinutes} )
        
        if [ $TimeComparison -eq 1 ] 
        then
            echo "Entering new product info into database.reason:products the same but meets time diff criteria"
	    EnterProductDataIntoDatabase ${WebsiteCode} "${ProductDescription}" ${Price} ${PercentOffMSRP} ${TotalQuantity} ${DurationInMinutes}
            GiveDatabaseTablenameDataEnterIntoDatabase  ${Database} ${Table} ${WebsiteCode} "${ProductDescription}" ${Price} ${PercentOffMSRP} ${TotalQuantity} ${DurationInMinutes}
        else
            echo "Product the same, but time difference too little from previous entry."
        fi
    fi
}

function GenericMySQLDatabaseQuery()
{
    MySQLHost=${1}
    MySQLPort=${2}
    MySQLDatabase=${3}
    MySQLUser=${4}
    MySQLPassword=${5}
    MySQLQuery="${6}"

   mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${MySQLQuery}"   --silent --skip-column-names 
#--column-names
#--xml
#--vertical
#--raw
#--silent --skip-column-names 
}


#----END - FUNCTIONS SPECIFIC TO PRODUCT DATABASE ------


function GiveProductKeywordDatabaseTablethenNotify()
{
    SentEmailTextAddressList=""
    SentEmailTextAddressList_arraycounter=0
    Product="${1}"

    ImageFile=${2}

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
            fi
        fi
    done 
}

function GiveProductProductImageEnterIntoDatabase()
{
    SentEmailTextAddressList=""
    SentEmailTextAddressList_arraycounter=0
    Product="${1}"
    ImageFile=${2}
    MySQLHost="mysql.server272.com"
    MySQLPort="3306"
    MySQLDatabase="djinnius_BackCountryAlerts"
    MySQLTableName="ProductImages"
    MySQLUser="BCA"
    MySQLPassword="backcountryalerts"
    flag=0

#check and see if the product all ready entered in database, expand variables here in a query string and then expand the $query in the dbase call   

    query="select image_id,filename from ${MySQLTableName} where filename=\"${Product}\""  

    databaserecords=$(mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${query}" --silent --skip-column-names  )
    databaserecordsSize=${#databaserecords}
    if [ $databaserecordsSize -ne 0 ]
    then

#we SHOULD only get one record back otherwise this isn't working the way I want it to
#TODO: make sure only 1 record is beign returned by creating a query that will erturn more than one results

	echo "Matching records primary_key:$databaserecords"
        Array=($(echo "${databaserecords}" )) 
        Primary_Key=${Array[0]}
	query="UPDATE ${MySQLTableName} SET number_of_times_seen=number_of_times_seen+1 where image_id=${Primary_Key}" 
	mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${query}" --silent
	flag=1
#insert 
# query="insert into ${MySQLTableName} 
    fi

    if [ ${flag} -eq 0 ] #then we haven't inserted that data into the database yet
    then 
	echo "Match not found in database, entering in ${Product} as a new item"
	query="insert into  ${MySQLTableName} (filename) value (\"${Product}\")"

	mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${query}" --silent


	Filename=$( ConvertForwardSlashToBackSlash "${Product}").jpg #this takes care of the only forbidden character for filenames the '/' since that is interpreted as a directory separator
    fi
}

#--------------------------
# BEGIN MAIN PART OF SCRIPT
#--------------------------

MySQLHost="mysql.server272.com"
MySQLPort="3306"
MySQLDatabase="djinnius_BackCountryAlerts"
MySQLUser="BCA"
MySQLPassword="backcountryalerts"

MySQLTableName="ProductImages" #not really passed to GenericMySQLDatabaseQuery
MySQLQuery="SELECT * FROM ${MySQLTableName} ORDER BY image_id DESC LIMIT 5 ;"
SearchProduct="Selle Italia SL XC Saddle"
MySQLQuery="SELECT * FROM ${MySQLTableName} WHERE filename=\"${SearchProduct}\";"
#MySQLQuery="SELECT * FROM ${MySQLTableName} WHERE image_id > 1700;" #returns no results
databaserecords=$(GenericMySQLDatabaseQuery ${MySQLHost} ${MySQLPort} ${MySQLDatabase}  ${MySQLUser} ${MySQLPassword} "${MySQLQuery}")

array=( $( for i in $databaserecords ; do echo $i ; done ) )
#echo "shit"
#for i in ${array[@]}
#do echo $i #this doesn't really work when fields have spaces in them
#done
#echo "shit2"
databaserecordsSize=${#databaserecords}
if [ $databaserecordsSize -ne 0 ]
then
    echo "Matching records primary_key:$databaserecords"
    echo "Db Records:$databaserecordsSize ..uhh this seems way to high for the query being limited to 5 results....ahh I bet it is the # of chars in the variable and not the # of records; yeah it appears to be the # of chars"
    echo "whassup"
    Array=($(echo "${databaserecords}" )) 
    Primary_Key=${Array[0]}
fi
MySQLTableName="ProductImages"
Query="SELECT timeEnter FROM ${MySQLTableName} WHERE websitecode=${WebsiteCode} ORDER BY Bkey DESC LIMIT 1" #return time of last product entered for a certain website
Query="SELECT dealdurationinminutes FROM ${MySQLTableName} WHERE websitecode=${WebsiteCode} ORDER BY Bkey DESC LIMIT 1" #return dealduration of last product entered for a certain website
Query="SELECT product FROM ${MySQLTableName} WHERE websitecode=${WebsiteCode} ORDER BY Bkey DESC LIMIT 1" #return last product entered into database for a certain website


MySQLTableName="Backcountrydeals"
WebsiteCode=2
MySQLQuery="SELECT product,dealdurationinminutes,timeEnter FROM ${MySQLTableName} WHERE websitecode=${WebsiteCode} ORDER BY Bkey DESC LIMIT 1" #return last product entered into database for a certain website

databaserecords=$(GenericMySQLDatabaseQuery ${MySQLHost} ${MySQLPort} ${MySQLDatabase}  ${MySQLUser} ${MySQLPassword} "${MySQLQuery}")
echo "${databaserecords}" # >> mysql.txt # dump and read from file


TAB=$(echo -e "\t")

{ IFS="$TAB" read a b c; } <<<  "$( mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${MySQLQuery}" --silent )"

echo "$a^$b^$c"
NumberOfRecordsToDisplay=1

#could alternately stick in a file but then again have to deal w the delimiter being a tab and not a space.
MySQLQuery="SELECT product,price,percentOffMSRP,quantity,dealdurationinminutes,timeEnter FROM Backcountrydeals WHERE websitecode=${WebsiteCode} ORDER BY Bkey DESC LIMIT ${NumberOfRecordsToDisplay}"
OIFS=$IFS
IFS=$TAB
mysql --host=${MySQLHost} --port=${MySQLPort} --database=${MySQLDatabase} --user=${MySQLUser} --password=${MySQLPassword} --execute="${MySQLQuery}" --silent --skip-column-names | while read databaserecords; do
    
    Array=($(echo "${databaserecords}" ))
    
    product="${Array[0]}"
    price=${Array[1]}
    echo "${product}^\$${price}"
done
IFS=$OIFS


#http://stackoverflow.com/questions/918886/split-string-based-on-delimiter-in-bash
#http://www.unix.com/shell-programming-scripting/104336-how-set-ifs-specific-command.html
MySQLQuery="SELECT ProductEntrykey FROM BackcountryProducts WHERE product=\"${SearchProduct}\";"

MySQLQuery="SELECT product,price,percentOffMSRP,quantity,dealdurationinminutes,timeEnter FROM Backcountrydeals WHERE websitecode=${WebsiteCode} ORDER BY Bkey DESC LIMIT ${NumberOfRecordsToDisplay}"
databaserecords=$(GenericMySQLDatabaseQuery ${MySQLHost} ${MySQLPort} ${MySQLDatabase}  ${MySQLUser} ${MySQLPassword} "${MySQLQuery}")
echo "results:${databaserecords}"
OIFS=$IFS
IFS=$TAB
Array=($(echo "${databaserecords}"))
product="${Array[0]}"
price=${Array[1]}
    echo "${product}-=-\$${price}"
IFS=$OIFS
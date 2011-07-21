
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
#----begin main
GivePageReturnDurationOfDealInMinutes "/tmp/SteepAndCheapPage"
GivePageReturnDurationOfDealInMinutes "/tmp/BonktownPage"

#ahh there was another older version of the function  which didn't take care fo the two cases that was being used. :/ need a better way to prevent this.

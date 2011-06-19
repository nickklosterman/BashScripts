#!/bin/bash
#OldIfs=$IFS
#IFS="\t"
echo "will perform grep ops on ${2}"
while read keyword phonenumber emailphone
do
echo ${keyword} 
echo ${phonenumber}
echo ${emailphone}
Match=$( grep "${keyword}" ${2} )
if [ "${Match}" != "" ]
then 
echo  "we have a match"
fi

done < ${1}


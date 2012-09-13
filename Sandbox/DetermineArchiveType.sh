#!/bin/bash
function determineArchiveType()
{
flag=2 #0 for zip, 1 for rar, 2 for unknown                                                                                                
filename="${1}"
file_output=$(file -b "${filename}")
file_output2=$(file -b "${filename}" | grep "Zip" -q )
file_output3=$(file -b "${filename}" |  awk '{ print $1}' )
file_output4=${file_output:0:3}
 
if grep "Zip" -q <<< "${filename}"
then
flag=0
else
flag=3
fi

if grep "RAR" -q <<< "${filename}"
then
flag=1
else 
flag=4
fi

#flag=99
if [ "${file_output3}" == "Zip" ]
then
flag=11
echo "zipp"
elif [ "${file_output3}" == "RAR" ]
then
flag=22
echo "rarrr"
else
flag=99
fi

#echo ${file_output}
echo -n "-${file_output3}-"
echo  "-${file_output4}-"
echo  "-${file_output}-"
echo $flag
}

for file in *.cb[rz]
do
    determineArchiveType "$file" #$file}
done
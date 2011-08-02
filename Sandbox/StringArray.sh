#!/bin/bash
function CheckArray()
{
    SearchArray=$1
    SearchTerm=$2
    if [ ${SearchArray[@]} =~ ${SearchTerm} ]
    then
	echo "Found"
    else
	echo "Not Found"
    fi
}
function CheckArray2()
{
    SearchArray=$1
echo $SearchArray
    SearchTerm=$2
echo $SearchTerm
    ArrayElements=${#SearchArray[@]}
echo $ArrayElements
    index=0
    while [ $index -lt $ArrayElements ]
    do
if grep -q ${SearchTerm} <<< "${SearchArray[$index]}"
#	if [ "${SearchArray[$index]}" =~ ${SearchTerm} ]
	then
	    echo "Found"
	else
	    echo "Not Found"
	fi
	let "index = $index + 1"
	echo $index
    done 
}

#begin script
Array=( one two three four five six seven )
PackedArray=`echo ${Array[@]}`
echo ${Array[*]}
echo ${PackedArray[*]}
CheckArray2 "${PackedArray}" "one"
CheckArray2 "${PackedArray}" "One"
#!/bin/bashfunction 
cleanFilename()
{
input="$1"
echo "-$input-"
output1=${input//[()&\'*[:space:]]} #remove crazy punctuation. can't use :punct: bc that'll strip out the period that delineates the file extension
output2=${output1//[[:space:]]}                           
output3= ${input//[()&\'*]}
#[\x27]} #<-- for some reason this trims off the last character, yet we don't need to use this trick to remove the apostrophe bc we can specify in the above pattern.
                               
echo "+${output1}+"
echo "<${output2}>"
echo ".${output3}."
}

for file in *.jpg
do
#echo "$@"
cleanFilename "${file}"
done
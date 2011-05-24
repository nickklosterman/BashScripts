#!/bin/bash
#STR="Hello Wordl!"
#echo $STR $#
#echo crap stuff

echo Starting number:$1 Ending number:$2 Number of digits:$3
if [ $# != 4 ]; #it causes problems when the $# is smack right up against the []
 signs
then echo Script_name start_number end_number number_of_digits file_extension
fi

if [ $# == 4 ];
then
echo Creating filelist.txt
for (( x = $1 ; x <= $2 ; x++))
do
case $3 in
3) y=$(printf "%03d" $x);;
4) y=$(printf "%04d" $x);;
esac
echo IMG_$y.jpg >> filelist.txt
done
#echo 'cat' filelist.txt
#exec grep -c *.jpg filelist.txt | grep :0
echo Creating inputfilelist.txt.
eval ls *.$4 > inputfilelist.txt
echo Creating missingfiles.txt.
eval grep -f filelist.txt inputfilelist.txt -v > missingfiles.txt
echo Removing inputfilelist.txt, filelist.txt.
eval rm inputfilelist.txt #perform cleanup
eval rm filelist.txt
echo These are the missing files:
eval cat missingfiles.txt
fi


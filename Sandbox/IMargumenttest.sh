#!/bin/bash
echo "1:${1}; 2:${2}"
image="${2}"
bob="${1}"
echo "${s}"
strarray=("${1}")
echo "arraycontents:${strarray[0]}-${strarray[1]}-${strarray[2]}-"
s="${1}" #first column:second column:third column"
set $s      # Breaks the string into $1, $2, ...
i=0
for item    # A for loop by default loop through $1, $2, ...
do
    echo "Element $i: $item"
    ((i++))
done


#mogrify "${i}" -resize 800x900 "${2}"
mogrify "${item}" -resize 800x900 "${image}"
#this won't work : bash ../IMargumenttest.sh '-modulate 150,50' img001.jpg

string="mogrify ${1} -resize 800x900 ${image}"
echo "${string}"
eval ${string}

#maybe try getting options from stdin and passing those to the mogrify command?
#or use an external exec command? so maybe that'll expand so it looks like the args are being "normally"
#make command a string and then run eval on that command.
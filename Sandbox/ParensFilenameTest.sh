#!/bin/bash
for file in *.jpg
do
echo "$file"
code="identify ${file}"
#eval "$code"
done

filename="bob spac & (99).jpg"
f1=${filename//[[:punct:]]}
f2=${filename//[[:space:]]}
f3=${f1//[[:space:]]}
f4=${filename/\(/} #this only works one pattern at a time.
f5=${filename/\&/}
f6=${filename//[()&]} #create our own regex character class
#[[:space:]]}
echo $'ring 3 times \a \a \a '
#"\a"
echo $'\102\141\163\150'

echo "$f1-$f2-$f3-$f4-$f5-$f6"

#no decode delegate error
#also need to figure out what {} "" etc do and when to use each and when to suse both
#-->research the above under Resources/bash.txt in parameter expansion

#filenames with parens in them,these cause probs but I thought I fixed this.
#filenames with ampersands
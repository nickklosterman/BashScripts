#!/bin/bash

#chars=( {A..z} {0..9} ) # this has some control chars in it
chars=( {A..Z} {a..z} {0..9} )
chars=( {a..z} {0..9} )
n=58

for ((i=0; i<${#chars[@]}; i++))
do
    for ((j=0; j<${#chars[@]}; j++))
    do
	echo "${chars[i]}${chars[j]}"
	mv /Users/nklosterman/.personal/Git/tumblrNodeSandbox/tumblr.jsTest/Media/${chars[i]}${chars[j]}*.* /Volumes/NO\ NAME/Media/
    done
done


# for i in {A..z}
# do
#     echo $i
# done

# for i in {0..9}
# do
#     echo $i
# done

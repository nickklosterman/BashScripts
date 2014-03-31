#!/bin/bash

until [  -z "${1}" ]
do
    filename="${1}"
    name=${filename%.*}
    extension=${filename##*.}
    if [ ${extension} -eq 'gif' ]
    then
	echo "If this is an animated gif being processed, running animate on the result file will cause a segfault"
    fi
    echo $name; echo $extension
    start=0
    while [ $start -lt 380 ]
    do 
	#convert ${filename} -modulate 100,100,${start} ${name}_${start}.${extension}
	convert ${filename} -modulate 100,100,${start} ${name}_${start}.gif
	#convert ${filename} -resize 50% -modulate 100,100,${start} ${name}_${start}.gif
	#echo ${start} ${name}_${start}${extension}  
	#echo $start
	let start+=20
    done

    gifsicle --delay 140 --loopcount  ${name}_*.gif > ${name}-anim.gif
    #gifsicle ${name}_*.gif -d 80 --loopcount > ${name}_anim.gif
    rm ${name}_*.gif
    animate ${name}-anim.gif
    shift 
done


#!/bin/bash


#temp="accArchive.main.html"
# wget http://www.abominable.cc/archive -o $temp

#http://abominable.cc/rss

timeOffset=1400000000
offset=30000000
endtimeOffest=1200000000
endtimeOffest=1180000000
while [ $timeOffset -ge $endtimeOffest ]
do
    echo "wget http://abominable.cc/archive?before_time=$timeOffset -o $timeOffset.html"
    wget http://abominable.cc/archive?before_time=$timeOffset -O $timeOffset.html
    let 'timeOffset-=offset'
done

for item in *.html
do
    grep post_notes $item   | sed 's/.*href=/wget /;s/">.*/"/' >> Posts.txt
done

sort -u Posts.txt >> Posts.txt

while read LINE
do
    filename=$( echo "${LINE}" | sed 's/.*\///;s/"//'  )
    #echo $filename

    if [ ! -e $filename ]
    then
        echo "NOT present! $filename"
        eval $LINE -O ${filename}.out
    fi

    #

done < Posts.txt


# for item in *.out ; do grep img "${item}" | grep media\.tumblr | grep -v avatar | sed 's/.*href=/ wget /;s/">.*/"/'; done

for item in *.out
do
    grep img "${item}" | grep media\.tumblr | grep -v avatar | sed 's/.*href=/ wget /;s/">.*/"/' >> ImgList.txt
done

while read LINE
do
    filename=$( echo "${LINE}" | sed 's/.*\///;s/"//'  )
    #echo $filename
    if [ ! -e $filename ]
    then
        echo "NOT present! $filename"
        eval $LINE -O ${filename}
    fi
done < ImgList.txt


#change filename to have the creation date as the first part of the filename such that they are sorted.
# for file in *; do f=${file%.*}; e=${file##.*; mv -- "$file" "$f-$(date +%Y%m%d -r "${file}.").${e}"; done
#for file in *.jpg; do f=${file%.*}; e=${file##*.}; cp -- "$file" "$(date +%Y%m%d -r "${file}")-${f}.${e}"; done

extensionArray=(*.jpg *.png *.gif)

for extension in "${extensionArray[@]}"
do
    for file in $extension
    do
        f=${file%.*}
        e=${file##*.}
        cp -- "$file" "$(date +%Y%m%d -r "${file}")-${f}.${e}"
        echo $extension $item
    done
done

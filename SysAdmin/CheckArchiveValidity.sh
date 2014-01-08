#!/bin/bash
myDate=`date +%F`
find . -name *.cbz  | xargs -I {} unzip -t {} > cbzcheck${myDate}.txt  
find . -name *.cbr  | xargs -I {} rar t {} > cbrcheck${myDate}.txt  
find . -name *.rar  | xargs -I {} rar t {} > rarcheck${myDate}.txt 
find . -name *.epub | xargs -I {} unzip -t {} > epubcheck${myDate}.txt 

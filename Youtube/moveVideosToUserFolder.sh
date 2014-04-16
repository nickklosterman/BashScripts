#!/bin/bash
user=${1}
sed "s/http:\/\/www.youtube.com\/watch?v=/mv */;s/$/* ${user}/" youtube_${user}_videolist.txt

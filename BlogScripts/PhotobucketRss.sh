#!/bin/bash
#  http://feed612.photobucket.com/albums/tt208/cormacru999/COMICS/CHRIS%20BACHELO/feed.rss

RSS="/tmp/rssfeed"
OUTPUT="tmp/rssfee.sh"
wget $1 -o $RSS
grep "<media:content" feed.rss.1 | sed 's/^.*"http/wget "http/;s/">/"/' > $OUTPUT
bash $OUTPUT



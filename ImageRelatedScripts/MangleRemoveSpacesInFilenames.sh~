#!/bin/bash
echo "<html><body><title>Main Page</title>" > index.html
for dir in *
do
    if [ -d "$dir" ]
    then
	echo "<a href=\"$dir/00Webpage.html\">$dir</a><br>" >>index.html
    fi
done
echo "</body></html>" >> index.html
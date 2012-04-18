#!/bin/bash
echo "<html><body><title>Main Page</title>" > index.html
find . -name 000*.html > /tmp/MangleWebPages.txt


while read LINE
do
    descrip=$( echo "$LINE" | sed 's/000.*//;s/.\///' )
    link=${LINE/.\//} #remove leading period and slash
    echo "<a href=\"$link\">$descrip</a><br>" >>index.html
done < /tmp/MangleWebPages.txt



echo "</body></html>" >> index.html
#!/bin/bash

dateyearstring=`date +%F| cut -c1-4`
datemonthstring=`date +%F| cut -c6-7`
datedaystring=`date +%F| cut -c9-10`
datedaystring=`date +%d`
datemonthstring=`date +%m`
short_dateyearstring=`date +%y`

#strip leading zeros so numbers not interpreted as octal
let datedaystring=10#$datedaystring+0
let datemonthstring=10#$datemonthstring+0

datemonthstring_formatted=$(printf "%02d" $datemonthstring);
datedaystring_formatted=$(printf "%02d" $datedaystring);

feh http://riptapparel.com/ript/wp-content/uploads/${dateyearstring}/${datemonthstring_formatted}/detail-${short_dateyearstring}${datemonthstring_formatted}${datedaystring_formatted}.jpg
 
echo "wget http://riptapparel.com/ript/wp-content/uploads/${dateyearstring}/${datemonthstring_formatted}/detail-${short_dateyearstring}${datemonthstring_formatted}${datedaystring_formatted}.jpg"

echo "I'm not really sure how to capture the sidebar for RiptApparel\n key off sidebar? is it in every post?"
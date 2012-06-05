#!/bin/bash

#http://www.bash-hackers.org/wiki/doku.php/syntax/arith_expr  very informative. gave me the solution for preventing interpretation as an octal.

datedaystringinit=8 #this will work
#to see this script work as desired comment the following line
datedaystringinit=08 #this breaks my script

echo $datedaystringinit
datedaystring=$(printf "%d\n" $((10#$datedaystringinit)));
echo $datedaystring
while [ $datedaystring -gt 0 ]; do

datedaystring_twodigitformat=$(printf "%02d" $datedaystring); 
datedaystring_shortformat=$(printf "%d" $datedaystring);
echo $datedaystring $datedaystring_twodigitformat $datedaystring_shortformat
 let "$(( 10#datedaystringinit)) -=1"
#awk "BEGIN { printf(\"%02d\", $datedaystring -1)}" #this won't throw an error but it also won't decremmnt my variable
done
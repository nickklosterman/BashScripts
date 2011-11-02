#!/bin/bash
# Script to split fields into tokens

# Here is the string where tokens separated by colons
s="first column:second column:third column"

IFS=":"     # Set the field separator
set $s      # Breaks the string into $1, $2, ...
i=0
for item    # A for loop by default loop through $1, $2, ...
do
    echo "Element $i: $item"
    ((i++))
done

#http://stackoverflow.com/questions/1617771/splitting-string-into-array
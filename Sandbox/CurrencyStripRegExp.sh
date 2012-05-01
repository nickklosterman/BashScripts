#!/bin/bash
number="$   67,800.99"
number=" $   67,800.99"
#number="   67,800.99"
echo "$number" | sed 's/\$//'
echo "$number" | sed 's/[^0-9]*//'
echo "$number" | sed 's/[^0-9]//'
echo "$number" | sed 's/$[^0-9]//'
echo "$number" | sed 's/\$.*[^0-9]//'
echo "$number" | sed 's/\..*//'
echo "$number" | sed 's/.*[^0-9]//'
echo "$number" | sed 's/\$[ ]?//'
echo "$number" | sed 's/[^0-9]*\..*//'
echo "$number" | sed 's/[^0-9]*//;s/\..*//;s/,//'
#echo "$number" | sed -n -e 's/\(*\)[^0-9]*\..*//'

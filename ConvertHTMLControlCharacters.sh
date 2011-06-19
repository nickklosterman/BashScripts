#!/bin/bash
sed 's/%26/\&/' $1 | sed 's/\%C2\%B0/°/g' | sed 's/\%2B/+/g' | sed 's/\%28/(/' | sed 's/\%29/)/' | sed 's/\%C3\%A0/à/'
#this is also not efficient for using sed. use the ; between statements instead of recalling sed each time and piping.
echo "Or you could pipe through recode"
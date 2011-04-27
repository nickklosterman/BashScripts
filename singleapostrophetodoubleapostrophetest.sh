#!/bin/bash
#sed 's/"'"/"'""'"/'  stuff.txt #this doesn't work
#sed "s/"'"/"'""'"/" stuff.txt #this doesn't work either
echo "you need to have created a text file called stuff.txt which has an apostrophe in it"

quot="'"
variafail=`sed 's/$quot/$quot$quot/' stuff.txt`
variawork=`sed "s/$quot/$quot$quot/" stuff.txt`
echo $variawork
echo $variafail
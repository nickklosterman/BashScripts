#!/bin/bash

NumberOfExpectedArguments=0

if [ $# -ne $NumberOfExpectedArguments ]
then
    echo "Please specify the number empty files to create."
    echo ""
else 
    for file in eibd*.pdf
    do 
	filename=$(echo $file |  sed -e 's/eibd//;s/.pdf//' )
	echo $filename >> $HOME/eibdearnings.txt
    done
fi



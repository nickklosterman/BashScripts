#!/bin/bash
 
#have the user input the index of the arg they want and the list of args. Then check if the array of args is that long and then output that arg. 
 #implement in python as well. 

index=0
for arg in "$@"
do 
    if [[ $index -eq $1 ]]
    then
	echo "EQ Arg #$index = $arg"
    fi
    echo "Arg #$index = $arg"
    let "index+=1"
done


#alternate form where you output the args as long as the index is less than the sentinel

index=0
for arg in "$@"
do 
    if [[ $index -le $1 ]]
    then
	echo "EQ Arg #$index = $arg"
    fi
    
    let "index+=1"
done

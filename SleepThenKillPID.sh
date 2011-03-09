#!/bin/bash
if [ $# -lt 1 ]
then 
echo "This program sleeps for 2hours then kills the pid given as an argument"
echo "Please provide the pid of the program you want killed in 2 hours."
else
date
#use env just in case it grabs the wrong sleep and gives unexpected results
env sleep 2h 2m 11s
echo "slept for a bit"
kill -9 $1
date
fi
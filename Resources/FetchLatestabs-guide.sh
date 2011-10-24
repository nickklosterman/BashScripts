#!/bin/bash
echo "This script will fetch abs-guide.pdf from http://tldp.ord/LDP/abs/abs-guide.pdf"
wget http://tldp.org/LDP/abs/abs-guide.pdf -q -N
#the -N should make it so that when a newer copy is found it overwrites the oldone.
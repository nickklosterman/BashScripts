#!/bin/bash

size=$( du $1 | cut -f 1) #i kept getting an error bc I forgot to cut.  The trailling . was being thrown into the arith expr and was screwing things up.
let '_5pct=size / 20' #
_5pct=$(($size / 20))
let 'total=size+55' #_5pct' #
sizeplusfive=$((size + _5pct))
((bill = size/20))

ten=10
five=5
echo $(( $ten / $five ))
echo $size _ $_5pct _ $sizeplusfive $bill
echo "doing df"
df
#!/bin/bash
item="${1}"
filename=${item%.*}

convert "$item" -unsharp 0.5x0.5+0.5+0.008 "$filename"_unsharp.jpg
convert 1200.jpg -unsharp 1.5x1.2+1.0+0.10 1200_unsharp2.jpg
convert 1200.jpg -unsharp 2.5x2.5+2.5+0.08 1200_unsharp2.jpg

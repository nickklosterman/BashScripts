#!/bin/bash
# this script is useful for shrinking down large gifs created from my EOS Rebel via the nodecreategifsfromcloseimages repo. Although the smart thing would be to shrink the images before gif creation.
# This is for shrinking medium resolution images (2818 x 1880) to 1/4 the size. Could put in some logic and read some options to change the output resolution. Possibly writ the shrink factor as part of the filename from the orig.
for item in IMG_0*.gif
do
    echo $item 
    outputFilename=${item%.*}
    gifsicle --resize 704x470 < $item > ${outputFilename}_small.gif
    #you can do this with IM as well, but you have to coalesce the gif first then resize. someone on SO stated that the IM result was larger than the gifsicle result
done
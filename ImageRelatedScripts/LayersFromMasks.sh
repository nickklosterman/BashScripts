echo "Usage: $0 filenamewithoutextension"
echo "This script is meant to take a image and, with masks in the same directory created by using the ImaceColorExtractor.sh script, and to 'cut out' those masked parts from the main image."
echo "It is meant to be used for digital decoupage."
echo "Did you run ImageColorExtractor.sh on your image first?"
if [ $# -eq 2 ]
then 
    tileFile=${1}
    filePrefix=${2}
    for image in $filePrefix*_*.png #if use ImageColorExtractor prior to this they will always be png
    do
	echo $image
	width=$( identify -format "%w" "$image" )
	height=$( identify -format "%h" "$image" )
	#http://www.imagemagick.org/Usage/masking/
	convert $image -size ${width}x${height} tile:${tileFile} -compose Multiply -composite $image.png #this produces our image masked properly but not with the alpha channel we want. #http://www.imagemagick.org/Usage/compose/#copyopacity
	convert -size ${width}x${height} $image.png  $image -compose CopyOpacity -composite $image.png.png  #this produces the masked image with the masked off areas transparent.
	mv $image.png.png $image.alphaoutline.png
	rm $image.png
    done

    feh *.alphaoutline.png
fi

#!/bin/bash
#print help message if -h given

ImageThreshold=30 #max number of images we'll allow before creating a set of pages with less images per page
imagesPerPage=28 #could also just set to $ImageThreshold
#crawl through directories and if the number of images is greater than a threshold then we'll create a set of webpages to split the 
#images across several webpages
for dir in *
do 
    if [ -d "$dir" ]
    then 
	cd "$dir" #need to move into directory 
#find number of images in the directory 
	numimages=$(  ls -1 *.[Jj][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg] 2>>/dev/null | wc -l ) 
#often there aren't gif or png but the ls will say "ls: cannot access *.png: No such file or directory" so need to discount above numbr by the number of times we see that message 
#	subtractnumimages=$( ls -1 *.[Jj][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg] | grep -c "No such file" ) #aaggh why doesn't this work?
#-->by redirecting stderr to /dev/null I dont get the "no such file or directory output"

	totalimages=$numimages #-subtractnumimages
echo "$totalimages >  $ImageThreshold"
#if the number of images crosses the threshold we'll make separate pages with fewer images per page
	if [[ "totalimages" -gt "$ImageThreshold" ]]
	then
	    echo "$dir will be split into separate smaller webpages"
	    counter=1
	    pagenum=$( printf "%02d" $counter )
	    HTMLpage="000$dir-$pagenum.html"
	    page=1
	    countermod=1
	    echo "<html><body><title>$dir pg $pagenum</title>" > $HTMLpage

	    for image in *.[jJ][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg]
	    do 
		if [ -f "$image" ] #prevents output when isn't a file; ie. catches when no images of one of the categories       
		then
		    
		    let "countermod = $counter % $imagesPerPage"
		    if  [ $countermod -eq 0 ] #signal need to create new page
		    then
			let 'pageplusone=page+1'
			pagenum=$( printf "%02d" $pageplusone )
			#place link to next page at end of present html page
			echo "<a href=\"000$dir-$pagenum.html\">Next Page</a>" >> "$HTMLpage"
			echo "</body></html>" >> "$HTMLpage" #close out last page
			let 'page+=1'
			pagenum=$( printf "%02d" $page )
			HTMLpage="000$dir-$pagenum.html"
			echo "$counter  $pagenum"
			echo "<html><body><title>$dir pg $pagenum</title>" > $HTMLpage #start new page
		    fi             
		    
#output image
		    echo "<hr>$counter<br>" >> "$HTMLpage"
		    echo "<img src=\"$image\"><br>" >> "$HTMLpage"
		    let 'counter+=1'
#		    echo $counter
		    
		    
		fi #end if its' an image
	    done #end processing images in jpg gif png
	fi #end processing if we're past the threshold and need to break into individ pages
	cd ..
    fi #end if its a dir
done #end processing directories


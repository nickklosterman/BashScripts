tempblogindex=/tmp/blogindex
wget $1 -O /tmp/blogindex
#download (with wget) the index file from the website you want to get images from

bash ~/Git/BashScripts/BlogScripts/GetAllBlogPages2.sh $tempblogindex
#this will create a whole bunch of search=... pages
cat $tempblogindex search* > filelist.txt
bash ~/Git/BashScripts/BlogScripts/GetBlogImagesNoClobber.sh filelist.txt

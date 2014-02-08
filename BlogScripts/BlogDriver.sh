tempblogindex=/tmp/blogindex
#--wget $1 -O $tempblogindex
#download (with wget) the index file from the website you want to get images from

#bash ~/Git/BashScripts/BlogScripts/GetAllBlogPages2.sh $tempblogindex
#---bash /home/puffjay/Repo/Github/BashScripts/BlogScripts/GetAllBlogPages2.sh $tempblogindex  #don't use v3 it has bugs and doesn't work

#this will create a whole bunch of search=... pages
cat $tempblogindex search* > filelist.txt
rm search*
bash /home/puffjay/Repo/Github/BashScripts/BlogScripts/GetBlogImagesNoClobber.sh filelist.txt
#/home/puffjay/Repo/Github/BashScripts/BlogScripts/GetBlogImagesNoClobber.sh

#crawl directories in teh DeviantArt and create a cbr/cbz from the image files in the directory. Do this for all directories

for item in `ls -d */`
do 
    echo ${item}
    cd ${item}
    pwd
    foo="${item::-1}"
    tar cf ${foo}.tar *
    #rm * #shit I needed to only remove files that were all BUT the tar :(
    cd ..
done

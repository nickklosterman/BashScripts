for item in `ls -d */`
do 
    filename_=${item^} 
    filename=${filename_%?}
    echo "zip ${filename} $item -r"
    zip ${filename} $item -r
    mv $filename.zip $filename.cbz
done

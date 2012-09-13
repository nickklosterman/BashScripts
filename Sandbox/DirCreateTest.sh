#!

function createDirectoryForWebcomic()
{   
    filename="${1}"
    foldernamenospaces="$filename" #$( convertFoldername "${filename}" ) #put here since would be called recursively in checkForFileNameCollision        
    number=0
    foldername="$foldernamenospaces"
while [[ -e "$foldername" && -d "$foldername" ]]
do  
    let 'number+=1'
    numberformat=$( printf "%02d" $number )
    foldername=$foldernamenospaces$numberformat
    echo "testing $foldername"
done
#mkdir "$foldername"
echo "this is the dire we would make:$foldername"

}

#start main
createDirectoryForWebcomic a
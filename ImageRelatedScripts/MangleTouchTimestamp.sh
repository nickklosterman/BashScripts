minute=2; for i in *.[Jj][Pp][Gg] ; do  echo "$i"; min=$( printf "%02d" $minute); echo $min ; touch -mt 2011020110${min} "$i" ; stat "${i}"; let 'minute+=1'; done
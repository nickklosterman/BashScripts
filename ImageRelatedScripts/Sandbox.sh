[bignicky@BigNicky TempShit]$ bob=cooki-1.txt; ns=${bob%-.}; echo $ns
cooki-1.txt
[bignicky@BigNicky TempShit]$ bob=cooki-1.txt; ns=${bob%-}; echo $ns
cooki-1.txt
[bignicky@BigNicky TempShit]$ bob=cooki-1.txt; ns=${bob%-*}; echo $ns
cooki
[bignicky@BigNicky TempShit]$ bob=cooki1.txt; ns=${bob%-*}; echo $ns
cooki1.txt
[bignicky@BigNicky TempShit]$ bob=cooki-1.txt; ns=${bob%-*}; echo $ns; if [ -f "$ns.jpg" ]  ; then echo "true" ; else echo "false" ; fi
cooki
false
[bignicky@BigNicky TempShit]$ touch cook0-1.txt
[bignicky@BigNicky TempShit]$ touch cook0.txt
[bignicky@BigNicky TempShit]$ bob=cook0-1.txt; ns=${bob%-*}; echo $ns; if [ -f "$ns.jpg" ]  ; then echo "true" ; else echo "false" ; fi
cook0
false
[bignicky@BigNicky TempShit]$ bob=cook0-1.txt; ns=${bob%-*}; echo $ns; name=$ns.jpg; if [ -f "$name" ]  ; then echo "true" ; else echo "false" ; fi
cook0
false
[bignicky@BigNicky TempShit]$ bob=cook0-1.txt; ns=${bob%-*}; echo $ns; name=$ns.jpg; echo "$name" ; if [ -f "$name" ]  ; then echo "true" ; else echo "false" ; fi
cook0
cook0.jpg
false
[bignicky@BigNicky TempShit]$ bob=cook0-1.txt; ns=${bob%-*}; echo $ns; if [ -f "$ns.txt" ]  ; then echo "true" ; else echo "false" ; fi
cook0
true
[bignicky@BigNicky TempShit]$ bob=cook0.txt; ns=${bob%-*}; echo $ns; if [ -f "$ns.txt" ]  ; then echo "true" ; else echo "false" ; fi
cook0.txt
false
[bignicky@BigNicky TempShit]$ bob=cook-0-.txt; ns=${bob%-*}; echo $ns; if [ -f "$ns.txt" ]  ; then echo "true" ; else echo "false" ; fi
cook-0
false
[bignicky@BigNicky TempShit]$ bob=cook-0-.txt; ns=${bob//[[:punct:]]}; echo $ns; if [ -f "$ns.txt" ]  ; then echo "true" ; else echo "false" ; fi
cook0txt
false

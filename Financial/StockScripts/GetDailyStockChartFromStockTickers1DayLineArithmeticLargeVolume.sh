#!/bin/bash

#for info on passing arrays:  http://stackoverflow.com/questions/1063347/passing-arrays-as-parameters-in-bash
#also 


#Other possible sources, usatoday,bloomberg,nyse,nasdaq, cbs marketwatch
#if stock on nasdaq vs nyse then need that to appropriately query the correct domain
#perform computer vision on chart?

#gdialog is just a wrapper for zenity


function BuildCharts()
{
    ticker="$1" 
    output_filename="$2" 
    chartoptions="$3"
    echo "http://chart.finance.yahoo.com/z?s=$1$3" >> "$2"
}




###Main###

debug=0

Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then
    echo "Usage: VerifyStockTickers ticker <ticker> ...."
else

#need to use getopts here
    outputfilename="/tmp/Charts" #"$2"

    if [ -e "$outputfilename" ]
    then
	rm "$outputfilename"
	echo "deleting $outputfilename"
    else
	echo "$outputfilename doesn't exist"
    fi


#have them select which menus want presented.
#could have each variable passed to next function and just keep appending output

#due to options being allowed to be blank we need to use an array otherwise if ema is blank but t1 isn't then t1 will show up in ma's variable slot in the function being called.    

    options="&t=1d&q=l&l=off&z=l&p=&a=v&c=&lang=en-US&region=US"
    until [ -z "$1" ] 
    do
	BuildCharts "$1" "$outputfilename" "$options"

#	BuildChartsWget "$1" "${ooutputfilenameWget}" "$options" #we had a variable in the BuildChartsWget and BuildCharts that was "outputfilename". Since functions inherit access to variables defined in the calling function, we were in fact re-assigning the value of outputfilename.  We saw the evidence of this as the first ticker wasn't being duplicated bc we hadn't reset the variable yet. Subsequent calls did show the duplication.

	shift 
    done

    if [ $debug -eq 0 ]
    then
	if [ ! -e  /tmp/TickerChartImages ]
	then
	    mkdir /tmp/TickerChartImages
	fi
	cd /tmp/TickerChartImages

	wget -q -i $outputfilename
#	bash $outpufilenameWget  # aagggh This doesn't work because then this kicks off the daughter process but doesn't complete this process, it also seemed to mess up the history as well as leave me in /tmp/TickerChartImages instead of the directory the script was called from ----> No this actually dumps you into a shell with in a shell after it executes. When you type "exit" it'll finally process the last few lines! I had called this multiple times so I had to type exit multiple times to back all teh way out of the multiple shells within shells.

	feh -S name /tmp/TickerChartImages #hmm don't wanna background cuz then images will be removed. and doing a noclobber with wget so the images wouldn't be update 
	rm -rf /tmp/TickerChartImages
    fi
fi
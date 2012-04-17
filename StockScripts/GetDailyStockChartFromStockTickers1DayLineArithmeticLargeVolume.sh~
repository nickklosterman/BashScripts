#!/bin/bash

#for info on passing arrays:  http://stackoverflow.com/questions/1063347/passing-arrays-as-parameters-in-bash
#also 


#Other possible sources, usatoday,bloomberg,nyse,nasdaq, cbs marketwatch
#if stock on nasdaq vs nyse then need that to appropriately query the correct domain
#perform computer vision on chart?

#gdialog is just a wrapper for zenity

function BuildOptions() 
{
    input=("${@}") #grab the passed array
    type=${input[0]} 
    scale=${input[1]} 
    span=${input[2]} 
    size=${input[3]} 
    ma=${input[4]}  
    ema=${input[5]} 
    t1=${input[6]} 
    t2=${input[7]}  
    compare=${input[8]} 
    regionlanguage=${input[9]} 
    if [ "$ma" != "" ]  
    then
	if [ "$ema" != "" ] && [ "$t1" != "" ] 
	then 
	    output="$ma,$ema,$t1"
	elif [ "$ma" != "" ] 
	then
	    output="$ma,$ema"
	elif [ "$t1" != "" ] 
	then
	    output="$ma,$t1"
	else 
	    output="$ma"
	fi
    else
	if [ "$ema" != "" ] && [ "$t1" != "" ] 
	then 
	    output="$ema,$t1"
	elif [ "$ema" != "" ] 
	then
	    output="$ema"
	elif [ "$t1" != "" ] 
	then
	    output="$t1"
	else
	    output=""
	fi
    fi

#if we don't use "${variable}" then variables break when right next to each other as well as causing problems with the &
    string="&t=${span}&q=${type}&l=${scale}&z=${size}&p=${output}&a=${t2}&c=${compare}${regionlanguage}"
    echo "$string"
}

function BuildCharts()
{
    ticker="$1" 
    output_filename="$2" 
    chartoptions="$3"
    echo "http://chart.finance.yahoo.com/z?s=$1$3" >> "$2"
}

function GetCharts()
{

    echo "http://chart.finance.yahoo.com/t?s=$1&lang=en-US&region=US&width=300&height=180" >> "$2"


    echo "http://chart.finance.yahoo.com/z?s=$1&t=1d&q=&l=&z=l&a=v&p=s&lang=en-US&region=US" >> "$2"

}

function GetChartType()
{
    gdialog --title "Select Chart Type" --backtitle "Yahoo! Finance Chart Creation Tool" --menu "Chart Type" 0 0 4 l "Line" b "Bar" c "Candle" 2> /tmp/ChartType.chart
    value=$(cat /tmp/ChartType.chart )
    echo "$value"
}
function GetChartScale()
{
    gdialog --title "Select Chart Scale" --yesno   "Use logarithmic scale?" 0 0
    if [ $? != 0 ]
    then
	echo "off" #use arithmetic scale
    else 
	echo "on" #use log scale
    fi
}
function GetChartTimeSpan()
{
    gdialog --title "Select Chart Time Span" --menu "Time Span" 0 0 4 1d "1 Day" 5d "5 Days" 3m "3 Months" 6m "6 Months" 1y "1 Year" 2y "2 Years" 5y "5 Years" my "Maximum"  2> /tmp/ChartTimeSpan.chart
    value=$(cat /tmp/ChartTimeSpan.chart )
    echo "$value"
}

function GetChartImageSize()
{
    gdialog --title "Select Chart Size" --menu "Image Size" 0 0 4 l "Large 800x475px" m "Medium 512x288px" s "Small 300x180px"  2> /tmp/ChartImageSize.chart
    value=$(cat /tmp/ChartImageSize.chart )
    echo "$value"
}
function GetMovingAverageIndicators()
{
    gdialog --title "Select Moving Average Length" --checklist "Moving Avg Ind" 0 0 4 m5 "5 Days" m5 m10 "10 Days" m10  m20 "20 Days" m20 m50 "50 Days" m50  m100 "100 Days" m100 m200 "200 Days" m200 2> /tmp/MovingAverageIndicators.chart 
    value=$(cat /tmp/MovingAverageIndicators.chart | sed 's/|/,/g' )
    echo "$value"
}
function GetExponentialMovingAverageIndicators()
{
    gdialog --title "Select Exponential Moving Average Length" --checklist "Exp Moving Avg Ind" 35 30 4 e5 "5 Days" e5 e10 "10 Days" e10 e20 "20 Days" e20 e50 "50 Days" e50 e100 "100 Days" e100 e200 "200 Days" e200 2> /tmp/ExponentialMovingAverageIndicators.chart
    value=$(cat /tmp/ExponentialMovingAverageIndicators.chart | sed 's/|/,/g' )
    echo "$value"
}
function GetTechnicalIndicators1()
{
    gdialog --title "Select Technical Indicators" --checklist "Technical Ind" 35 30 4  v "Volume" v b "Bollinger Bands" b p "Parabolic Stop and Reverse" p s "Splits" s 2> /tmp/TechnicalIndicators1.chart
    value=$(cat /tmp/TechnicalIndicators1.chart | sed 's/|/,/g' )
    echo "$value"
}

function GetTechnicalIndicators2()
{
    gdialog --title "Select Technical Indicators 2 (show up below stock chart)" --checklist "Technical Ind 2" 0 0 4 fs "Stochastic" fs m26-12-9 "Moving-Average-Convergence-Divergence" m26-12-9 f14 "Money Flow Index" f14 p12 "Rate of Change" p12 r14 "Relative Strength Index" r14 ss "Slow Stochastic" ss v "Volume" v vm "Volume with Moving Average" vm w14 "Williams Percent Range" w14 2> /tmp/TechnicalIndicators2.chart
    value=$(cat /tmp/TechnicalIndicators2.chart | sed 's/|/,/g' )
    echo "$value"
}

function GetCompareTo()
{
    gdialog --title "Enter Tickers or Indices to Compare to" --inputbox "Comparison" 0 0 "Separate with commas" 2>/tmp/CompareTo.chart
    value=$(cat /tmp/CompareTo.chart )
    if [ "$value" == "Separate with commas" ]
    then 
	value=""
    fi
    echo "$value"
}
function GetRegionLanguage()
{
#gdialog --title 
#    return "&lang=en-US&region=US"
    echo "&lang=en-US&region=US"
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

    ooutputfilenameWget="/tmp/ChartsWget" #"$2"

    if [ -e "$outputfilename" ]
    then
	rm "$outputfilename"
	echo "deleting $outputfilename"
    else
	echo "$outputfilename doesn't exist"
    fi

    if [ -e "$ooutputfilenameWget" ]
    then
	rm "$ooutputfilenameWget"
	echo "deleting $ooutputfilenameWget"
    else
	echo "$ooutputfilenameWget doesn't exist"
    fi
    echo "$outputfilename $ooutputfilenameWget"

#have them select which menus want presented.
#could have each variable passed to next function and just keep appending output

    if [ $debug -eq 0 ] 
    then
	type=$( GetChartType )
	scale=$( GetChartScale )
	span=$( GetChartTimeSpan )
	size=$( GetChartImageSize )
	ma=$( GetMovingAverageIndicators )
	ema=$( GetExponentialMovingAverageIndicators )
	t1=$( GetTechnicalIndicators1 )
	t2=$( GetTechnicalIndicators2 )
	compare=$( GetCompareTo )
	regionlanguage=$( GetRegionLanguage )
	if [ "$GetChartType" == "" ]
	then
	    GetChartType="l"
	fi
	if [ "$GetChartScale" == "" ]
	then
	    GetChartScale="off"
	fi
	if [ "$GetChartTimeSpan" == "" ]
	then
	    GetChartTimeSpane="5d"
	fi
	if [ "$GetChartImageSize" == "" ]
	then
	    GetChartImageSize="l"
	fi
    fi


#due to options being allowed to be blank we need to use an array otherwise if ema is blank but t1 isn't then t1 will show up in ma's variable slot in the function being called.    
    OptionsArray=( "$type"  "$scale"  "$span"  "$size"  "$ma"  "$ema"  "$t1"  "$t2"  "$compare"  "${regionlanguage}" ) #construct the array

    if [ $debug -eq 1 ]
    then
	options="&t=3m&q=l&l=off&z=l&p=v&a=&c=&lang=en-US&region=US"
    else
	options=$( BuildOptions "${OptionsArray[@]}" ) #pass array
    fi

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
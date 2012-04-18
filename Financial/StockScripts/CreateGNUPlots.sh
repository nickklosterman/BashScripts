#!/bin/bash
sqlite3 /home/arch-nicky/IBDdatabase.sqlite "select DISTINCT(StockTicker) from IBD50 ORDER BY  StockTicker ASC" > /tmp/StockTickers.txt #/$HOME/StockTickers.txt #/tmp/StockTickers.txt
while read line
do
#query the sqlite database
#store query result in /tmp/sample.dat file
#call gnuplot 
    sqlite3 /home/arch-nicky/IBDdatabase.sqlite "select Date,Rank from IBD50 where StockTicker=\"${line}\" ORDER BY Date ASC" > /tmp/sample.dat
#    command=$( sed "s/VARIABLE/${line}/" /home/arch-nicky/Git/BashScripts/GnuplotScripts/StockTickerData.txt | gnuplot )
#exec $command
     sed "s/VARIABLE/${line}/" /home/arch-nicky/Git/BashScripts/GnuplotScripts/StockTickerData.txt | gnuplot 
done < "/tmp/StockTickers.txt" #"/$HOME/StockTickers.txt" #

echo "I need to write a script that sets datapoints to 55 or something off the chart for when their is no data (ie. they are no longer ranked)"
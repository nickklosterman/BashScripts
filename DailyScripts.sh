#!/bin/bash
#sudo killall clamd
#only start process if not all ready running
DEBUG=0 #

#go off the exit status of the previously executed command
ps aux | grep -q "guake" | grep -v grep  > /dev/null
if [ $? -eq 1 ] #exit status of 0 means true, 1 means false
then
    guake &
else
    echo "guake all ready running"
fi

ps aux | grep -q "conky" | grep -v grep > /dev/null
if [ $? -eq 1 ]
then 
#    conky &
    bash ~/.conkystartup2.sh &
else
    echo "conky all ready running"
fi


if [ $DEBUG -eq 0 ] 
then
bash ~/Git/BashScripts/DDdailyimagegetter.sh &
bash ~/Git/BashScripts/WebComics/Sinfest/sinfestgetXdaysV2.sh 1 &
bash ~/Git/BashScripts/DealScrapers/GetAllDailyDeals.sh &

/bin/sleep 18 #wait a bit before getting the weather so it isn't overwritten with wget status
bash ~/Git/BashScripts/Weather/DaytonWeather.sh #& when backgrounding the stock trackers were partially executing before the weather kicked in
python ~/Git/PythonStockTracker/StockTracker.py ~/Git/PythonStockTracker/StockData.txt
python ~/Git/PythonStockTracker/StockTracker.py ~/Git/PythonStockTracker/TRowePrice.txt
fi
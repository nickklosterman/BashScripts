#!/bin/bash
#sudo killall clamd
bash ~/.conkystartup2.sh &
bash ~/Git/BashScripts/DDdailyimagegetter.sh &
bash ~/Git/BashScripts/WebComics/Sinfest/sinfestgetXdaysV2.sh 1 &
bash ~/Git/BashScripts/DealScrapers/GetAllDailyDeals.sh &

/bin/sleep 18 #wait a bit before getting the weather so it isn't overwritten with wget status
bash ~/Git/BashScripts/Weather/DaytonWeather.sh #& when backgrounding the stock trackers were partially executing before the weather kicked in
python ~/Git/PythonStockTracker/StockTracker.py ~/Git/PythonStockTracker/StockData.txt
python ~/Git/PythonStockTracker/StockTracker.py ~/Git/PythonStockTracker/TRowePrice.txt
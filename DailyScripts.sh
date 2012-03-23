#!/bin/bash
bash ./DDdailyimagegetter.sh &
cd ~/Git/BashScripts
bash sinfestgetXdaysV2.sh 1 &
cd DealScrapers
bash GetAllDailyDeals.sh &
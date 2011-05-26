#!/bin/bash
echo $@
gnuplot ~/Git/BashScripts/GnuplotScripts/PercentOffMSRPvsDealDurationGnuplot.txt
gnuplot ~/Git/BashScripts/GnuplotScripts/PercentOffMSRPvsQuantityGnuplot.txt
gnuplot ~/Git/BashScripts/GnuplotScripts/PricevsDealDurationGnuplot.txt
gnuplot ~/Git/BashScripts/GnuplotScripts/PricevsPercentOffMSRPGnuplot.txt
gnuplot ~/Git/BashScripts/GnuplotScripts/PricevsQuantityGnuplot.txt
gnuplot ~/Git/BashScripts/GnuplotScripts/PricevsQuantityvsDealDurationGnuplot.txt
gnuplot ~/Git/BashScripts/GnuplotScripts/QuantityvsDealDurationGnuplot.txt
gnuplot ~/Git/BashScripts/GnuplotScripts/WebsitecodevsDealDurationGnuplot.txt
gnuplot ~/Git/BashScripts/GnuplotScripts/WebsitecodevsPercentOffMSRPGnuplot.txt
gnuplot ~/Git/BashScripts/GnuplotScripts/WebsitecodevsQuantityGnuplot.txt
gnuplot ~/Git/BashScripts/GnuplotScripts/WebsitecodevsPriceGnuplot.txt
bash ~/Git/BashScripts/DealScrapers/BackcountryWebsites/UploadMultipleFilesMPUTToDjinniusDeals.sh "nM&^%4Yu" "~/Desktop/sqlite_examples/*nuplot.png"
#without the quotes 

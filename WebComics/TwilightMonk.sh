#!/bin/bash

wget http://www.twilightmonk.com/category/comic-pages/
grep mini index.html | sed 's/.*img src="/wget /;s/".*//;s/-mini//' > GetTwilightMonk.sh
bash GetTwilightMonk.sh


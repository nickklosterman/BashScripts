#!/bin/bash
sqlite3 test.db "select product from Backcountrydeals;" > DatabaseDump.txt
sed '/^$/d' DatabaseDump.txt | sort | uniq -c | sort -n



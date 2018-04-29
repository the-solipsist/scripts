#!/usr/bin/env bash

hledger stats | grep -o '\bINF\w*' > /tmp/hledger-commodities

curl -s https://www.amfiindia.com/spages/NAVAll.txt | \
grep -f /tmp/hledger-commodities | \
tr -d '\r' | \
awk -F";" '{printf("\"%s\" %s ",$2,"₹"$5);system("date -d "$8" +%Y-%m-%d");}' | \
awk '{print "P",$3,$1,$2 }' | \
tee -a rates.journal

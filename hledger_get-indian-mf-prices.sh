#!/usr/bin/env bash
ledger_dir=$HOME/Accounts
rates_file=$ledger_dir/rates.journal

hledger stats | grep -o '\bINF\w*' > /tmp/hledger-mf-commodities

curl -s https://www.amfiindia.com/spages/NAVAll.txt | \
grep -f /tmp/hledger-mf-commodities | \
tr -d '\r' | \
awk -F";" '{printf("\"%s\" %s ",$2,"₹"$5);system("date -d "$8" +%Y-%m-%d");}' | \
awk '{print "P",$3,$1,$2 }' | \
tee -a $rates_file

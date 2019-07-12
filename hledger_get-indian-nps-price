#!/usr/bin/env bash
LEDGER_DIR=~/Accounts
RATES_FILE=$LEDGER_DIR/rates.journal

hledger stats | grep -o '\bSM\w*' > /tmp/hledger-nps-commodities

d=$(date -d yesterday +%d%m%Y) ;

curl -sL "https://npscra.nsdl.co.in/download/NAV_File_$d.zip" | \
bsdtar -f- -xC /tmp/ ;

cat /tmp/NAV_File_$d.out | \
grep -f /tmp/hledger-nps-commodities | \
tr -d '\r' | \
awk -F"," '{printf("\"%s\" %s ",$4,"₹"$6);system("date -d "$1" +%Y-%m-%d");}' | \
awk '{print "P",$3,$1,$2}' | \
tee -a $RATES_FILE

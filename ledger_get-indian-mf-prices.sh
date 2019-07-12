#!/usr/bin/env bash
ledger_dir=$HOME/Accounts
all_j=$ledger_dir/all.journal
rates_file=$ledger_dir/rates.journal

if type ledger 2>/dev/null
   then
   ledger -f $all_j  commodities | grep -o '\bINF\w*' > /tmp/ledger-mf-commodities
elif type hledger 2>/dev/null
   then
   hledger stats | grep -o '\bINF\w*' > /tmp/hledger-mf-commodities
else
   echo "Neither ledger nor hledger is present"
fi

curl -s https://www.amfiindia.com/spages/NAVAll.txt | \
grep -f /tmp/hledger-mf-commodities | \
tr -d '\r' | \
awk -F";" '{printf("\"%s\" %s ",$2,"₹"$5);system("date -d "$8" +%Y-%m-%d");}' | \
awk '{print "P",$3,$1,$2 }' | \
tee -a $rates_file

#!/usr/bin/env bash
ledger_dir=$HOME/Accounts
all_file=$ledger_dir/all.journal
rates_file=$ledger_dir/rates.journal

if type ledger &>/dev/null
   then
   ledger -f $all_file commodities | grep -o '\bINF\w*' > /tmp/ledger-mf-commodities
elif type hledger &>/dev/null
   then
   hledger -f $all_file stats | grep -o '\bINF\w*' > /tmp/ledger-mf-commodities
else
   echo "Neither ledger nor hledger is present"
fi

curl -s https://www.amfiindia.com/spages/NAVAll.txt | \
grep -f /tmp/ledger-mf-commodities | \
tr -d '\r' | \
awk -F";" '{printf("\"%s\" %s ",$2,"₹"$5);system("date -d "$6" +%Y-%m-%d");}' | \
awk '{print "P",$3,$1,$2 }' | \
tee -a $rates_file

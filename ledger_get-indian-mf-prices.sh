#!/usr/bin/env bash
ledger_dir=$HOME/accounts
all_file=$ledger_dir/all.journal
rates_file=$ledger_dir/rates_mf.journal

if type ledger &>/dev/null
   then
   ledger -f $all_file commodities | grep -o '\bINF\w*' > /tmp/ledger-mf-commodities
elif type hledger &>/dev/null
   then
   hledger -f $all_file stats | grep "^Commodities" | grep -o '\bINF\w*' > /tmp/ledger-mf-commodities
else
   echo "Neither ledger nor hledger is present"
fi

curl -s https://www.amfiindia.com/spages/NAVAll.txt | \
grep -f /tmp/ledger-mf-commodities | \
tr -d '\r' | \
awk -F";" '{printf("\"%s\";%s;%s;",$2,"₹"$5,$4);system("date -d "$6" +%Y-%m-%d")}' | \
awk -F";" '{print "P",$4,$1,$2 "\t""  ; "$3}' | \
sponge -a $rates_file
awk ' !x[$0]++' $rates_file | tail -n 20

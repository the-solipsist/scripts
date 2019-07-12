#!/usr/bin/env bash
ledger_dir=$HOME/Accounts
all_j=$ledger_dir/all.journal
rates_file=$ledger_dir/rates.journal

if type ledger &>/dev/null
   then
   ledger -f $all_j commodities | grep -o '\bSM\w*' > /tmp/ledger-nps-commodities
elif type hledger &>/dev/null
   then
   hledger -f $all_j stats | grep -o '\bSM\w*' > /tmp/ledger-nps-commodities
else
   echo "Neither ledger nor hledger is present"
fi

d=$(date -d yesterday +%d%m%Y) ;

curl -sL "https://npscra.nsdl.co.in/download/NAV_File_$d.zip" | \
bsdtar -f- -xC /tmp/ ;

cat /tmp/NAV_File_$d.out | \
grep -f /tmp/ledger-nps-commodities | \
tr -d '\r' | \
awk -F"," '{printf("\"%s\" %s ",$4,"₹"$6);system("date -d "$1" +%Y-%m-%d");}' | \
awk '{print "P",$3,$1,$2}' | \
tee -a $rates_file

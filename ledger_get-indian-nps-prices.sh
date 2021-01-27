#!/usr/bin/env bash
# Use the scheme ID (e.g. "SM001001") as the commodity symbol for the NPS units.
# You can find the scheme ID from this website: https://npscra.nsdl.co.in/nav-search.php
# The scheme IDs follow the pattern SMXXXYYY 
#     where XXX = PFM number (from 001 to 010, as of 2021-01-28) 
#     and YYY = scheme number (from 001 to 014, depending on which schemes are offered by the PFM)
ledger_dir=$HOME/accounts
all_file=$ledger_dir/all.journal
rates_file=$ledger_dir/rates.journal

if type ledger &>/dev/null
   then
   ledger -f $all_file commodities | grep -o '\bSM\w*' > /tmp/ledger-nps-commodities
elif type hledger &>/dev/null
   then
   hledger -f $all_file stats | grep -o '\bSM\w*' > /tmp/ledger-nps-commodities
else
   printf "Neither ledger nor hledger is present"
fi

n=0

while [ $n -gt -1 ]
do
  d=$(date -d "- $n days" +%d%m%Y)
  CODE=$(curl -sL -w '%{http_code}' "https://npscra.nsdl.co.in/download/NAV_File_$d.zip" -o "/tmp/NAV_File_$d.zip")
  if [[ $CODE = 404 ]]; then
    n=$[$n+1]
  else
    n=-1
  fi
done

bsdtar -xf "/tmp/NAV_File_$d.zip" -C /tmp/ ;

cat /tmp/NAV_File*.out | \
grep -f /tmp/ledger-nps-commodities | \
tr -d '\r' | \
awk -F"," '{printf("\"%s\" %s ",$4,"₹"$6);system("date -d "$1" +%Y-%m-%d");}' | \
awk '{print "P",$3,$1,$2}' | \
tee -a $rates_file

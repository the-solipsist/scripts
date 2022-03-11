#!/usr/bin/env bash
# Use the scheme ID (e.g. "SM001001") as the commodity symbol for the NPS units.
# You can find the scheme ID from this website: https://npscra.nsdl.co.in/nav-search.php
# The scheme IDs follow the pattern SMXXXYYY 
#     where XXX = PFM number (from 001 to 010, as of 2021-01-28) 
#     and YYY = scheme number (from 001 to 014, depending on which schemes are offered by the PFM)
LEDGER_DIR=~/accounts
RATES_FILE=$LEDGER_DIR/rates_nps.journal
#journal=$ledger_dir/latest.journal

#if type ledger &>/dev/null
#   then
#   ledger -f $journal commodities | grep -o '\bSM\w*' > /tmp/ledger-nps-commodities
#elif type hledger &>/dev/null
#   then
#   hledger -f $journal commodities | grep -o '\bSM\w*' > /tmp/ledger-nps-commodities
#else
#   printf "Neither ledger nor hledger is present"
#fi

hledger commodities | grep -o '\bSM\w*' > /tmp/hledger-nps-commodities

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

cat /tmp/NAV*.out | \
grep -f /tmp/hledger-nps-commodities | \
sort | \
tr -d '\r' | \
awk -F"," '{printf("\"%s\";%s;%s;",$4,"₹"$6,$5);system("date -d "$1" +%Y-%m-%d");}' | \
awk -F';' '{print "P",$4,$1,$2 "\t""  ; "$3}' | \
sponge -a $RATES_FILE
rm /tmp/NAV*.out
awk ' !x[$0]++' $RATES_FILE | tail -n 6

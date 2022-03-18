#!/usr/bin/env bash
###############################################################################
# Script to download latest rates for NPS schemes and save the price in ledger
#  format
# Use the scheme ID (e.g. "SM001001") as the commodity symbol for the NPS units.
# You can find the scheme ID from this website:
#  https://npscra.nsdl.co.in/nav-search.php
# The scheme IDs follow the pattern SMXXXYYY
#  where XXX = PFM number (from 001 to 010, as of 2021-01-28)
#  and YYY = scheme number (from 001 to 014, depending on which
#  schemes are offered by the PFM)
###############################################################################
ledger_dir=~/accounts
rates_file=$ledger_dir/rates_nps.journal

hledger commodities | grep -o '\bSM\w*' > /tmp/hledger-nps-commodities

n=0
date=$(date "+%d%m%Y")

print_rate() {
  gunzip -k </tmp/NAV_File_$d.zip \
    | grep -f /tmp/hledger-nps-commodities \
    | sort \
    | awk -F"," '{printf("\"%s\";%s;%s;",$4,"₹"$6,$5);system("date -d "$1" --iso-8601");}' \
    | awk -F';' '{print "P",$4,$1,$2 "\t""  ; "$3}' \
    | sponge -a $rates_file
}

if [ -s /tmp/NAV_File_${date}.zip ]; then
  tail -n 6 $rates_file
  exit
else
  while [[ $n -gt -1 ]]; do
    d=$(date -d "- $n days" "+%d%m%Y")
    url="https://npscra.nsdl.co.in/download/NAV_File_$d.zip"
    code=$(curl -fOL -w '%{http_code}' "$url" --output-dir /tmp/)
    if [[ $code = 404 ]]; then
      (( n=n+1 ))
    else
      n=-1
      print_rate
    fi
  done
fi

awk ' !x[$0]++' $rates_file | sponge $rates_file
tail -n 6 $rates_file

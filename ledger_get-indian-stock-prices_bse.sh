#!/usr/bin/env bash

ledger_dir=~/accounts
rates_file=$ledger_dir/rates_stocks.journal
url="https://www.bseindia.com/download/BhavCopy/Equity/"
date=$(date "+%d%m%y")
n=0

print_rates() {
  gunzip </tmp/EQ_ISINCODE_${date}.zip \
    | grep -f /tmp/hledger-stock-commodities \
    | sort \
    | tr -d '\r' \
    | awk -F"," '{printf("\"%s\";%s;%s;",$15,"₹"$8,$2);system("date -d "$16" -I");}' \
    | awk -F";" '{print "P",$4,$1,$2 "\t""  ; "$3}' \
    | sponge -a $rates_file
}

hledger commodities | grep -E '^IN.[0-9]+' > /tmp/hledger-stock-commodities

if [ -s /tmp/EQ_ISINCODE_${date}.zip ]; then
  tail -n 10 $rates_file
  exit
else
  while [ $n -gt -1 ];  do
    date=$(date -d "- $n days" "+%d%m%y")
    full_url="$url/EQ_ISINCODE_${date}.zip"
    curl_opts=( --silent --location --output-dir "/tmp" --fail --remote-name)
    code=$(curl -w "%{http_code}" "${curl_opts[@]}" "$full_url")
    if [[ $code = 200 ]]; then
      n=-1
      echo $full_url
      echo $code
    else
      ((n=n+1))
      echo $full_url
      echo $code
    fi
  done
fi

print_rates
awk ' !x[$0]++' $rates_file \
  | sponge $rates_file
tail -n 10 $rates_file

#!/usr/bin/env bash

ledger_dir=~/accounts
rates_file=$ledger_dir/rates_stocks.journal
url="https://www1.nseindia.com/content/historical/EQUITIES"
ua="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:98.0) Gecko/20100101 Firefox/98.0"
ref="https://www1.nseindia.com/products/content/equities/equities/archieve_eq.htm"
date=$(date "+%d%^^b%Y")
n=0

print_rates() {
  gunzip </tmp/cm${date}bhav.csv.zip \
    | grep -f /tmp/hledger-stock-commodities \
    | sort \
    | tr -d '\r' \
    | awk -F"," '{printf("\"%s\";%s;%s;",$13,"₹"$6,$1);system("date -d "$11" -I");}' \
    | awk -F";" '{print "P",$4,$1,$2 "\t""  ; "$3}' \
    | sponge -a $rates_file
}

hledger commodities | grep -E '^IN.[0-9]+' > /tmp/hledger-stock-commodities

if [ -s /tmp/cm${date}bhav.csv.zip ]; then # don't download if already downloaded
  tail -n 10 $rates_file
  exit
else
  while [ $n -gt -1 ];  do
    date=$(date -d "- $n days" "+%d%^^b%Y")
    month=$(date -d "-$n days" "+%^^b")
    year=$(date -d "- $n days" "+%Y")
    full_url="$url/$year/$month/cm${date}bhav.csv.zip"
    curl_opts=( --silent --referer "$ref" --user-agent "$ua" \
      --location --output-dir "/tmp" --fail --remote-name)
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

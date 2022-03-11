#!/usr/bin/env bash

LEDGER_DIR=~/accounts
RATES_FILE=$LEDGER_DIR/rates_stocks.journal

hledger commodities | grep -o '\bIN\w*' > /tmp/hledger-stock-commodities

n=0
URL="https://www1.nseindia.com/content/historical/EQUITIES"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"
REF="https://www1.nseindia.com/products/content/equities/equities/archieve_eq.htm"

while [ $n -gt -1 ]
do
  date=$(date -d "- $n days" +%d)
  month=$(date -d "- $n days" +%b)
  month=${month^^}
  year=$(date -d "- $n days" +%Y)
  CODE=$(curl -sL -w '%{http_code}' "$URL/$year/$month/cm$date$month${year}bhav.csv.zip" --referer "$REF" --user-agent "$UA" --output "/tmp/cm${date}${month}${year}bhav.csv.zip")
   if [[ $CODE = 200 ]]; then
    n=-1
    echo $CODE
   else
    n=$[$n+1]
    echo $REF
    echo "$URL/$year/$month/cm${date}${month}${year}bhav.csv.zip"
    echo $CODE
   fi
done

bsdtar -xf "/tmp/cm$date$month${year}bhav.csv.zip" -C /tmp/ ;

cat /tmp/cm*.csv | \
grep -f /tmp/hledger-stock-commodities | \
sort | \
tr -d '\r' | \
awk -F"," '{printf("\"%s\";%s;%s;",$13,"₹"$6,$1);system("date -d "$11" +%Y-%m-%d");}' | \
awk -F";" '{print "P",$4,$1,$2 "\t""  ; "$3}' | \
sponge -a $RATES_FILE
rm /tmp/cm*.csv
awk ' !x[$0]++' $RATES_FILE | sponge $RATES_FILE
tail -n 10 $RATES_FILE

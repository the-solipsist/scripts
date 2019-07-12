#!/usr/bin/env bash
ledger_dir=~/Accounts
rates_file=$LEDGER_DIR/rates.journal

. $ledger_dir/alphavantage-api.key

hledger stats | grep -E '^Commodities' | grep -o '\b(NSE|BSE)\w*' > /tmp/hledger-stocks
readarray -t stocks < /tmp/hledger-stocks


for foreign_currency in "${foreign_currencies[@]}"
do
  curl -s  $site | \
  extract_rate | \

for stock in "${stocks[@]}"
do
  curl -s "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$stock&apikey=$key" | \
  jq -r '.[]."05. Price"' | \
  awk -v c=$STOCK '{print "P",strftime("%Y-%m-%d"),"\""c"\"","₹"$1}' | \
  tee -a $rates_file
  sleep 15s #rate limit to keep the API happy
done

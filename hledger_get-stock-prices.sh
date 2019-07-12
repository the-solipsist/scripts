#!/usr/bin/env bash
ledger_dir=~/Accounts
rates_file=$LEDGER_DIR/rates.journal

# Store API in a file named alphavantage-api that states `key=ZCDCI5WLTC3WE2BX` with your API key.
. $ledger_dir/alphavantage-api.key

# I use "exchange:symbol" as the commodity name to make it easier to search online.
# I couldn't find a way to make Alphavantage work with ISIN.
# If you want to add more commodities, do so by adding to (NSE:|BSE:|NASDAQ:) and so on.
hledger stats | grep -E '^Commodities' | grep -Eo '\b(NSE:|BSE:)\w*' > /tmp/hledger-stocks
readarray -t stocks < /tmp/hledger-stocks

for stock in "${stocks[@]}"
do
  curl -s "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$stock&apikey=$key" | \
  jq -r '.[]."05. Price"' | \
  awk -v c=$stock '{print "P",strftime("%Y-%m-%d"),"\""c"\"","₹"$1}' | \
  tee -a $rates_file
  sleep 15s #rate limit to keep the API happy
done

#!/usr/bin/env bash
ledger_dir=~/Accounts
all_j=$ledger_dir/all.journal
rates_file=$ledger_dir/rates.journal

# Store API in a file named alphavantage-api that states `key=ZCDCI5WLTC3WE2BX` with your API key.
. $ledger_dir/alphavantage-api.key

# I use "exchange:symbol" as the commodity name to make it easier to search online.
# I couldn't find a way to make Alphavantage work with ISIN.
# If you want to add more commodities, do so by adding to (NSE:|BSE:|NASDAQ:) and so on.
if type ledger &>/dev/null
   then
   ledger -f $all_j commodities | grep -Eo '\b(NSE:|BSE:)\w*' > /tmp/ledger-stocks
elif type hledger &>/dev/null
   then
   hledger -f $all_j stats | grep -E '^Commodities' | grep -Eo '\b(NSE:|BSE:)\w*' > /tmp/ledger-stocks
else
   echo "Neither ledger nor hledger is present"
fi

readarray -t stocks < /tmp/ledger-stocks

for stock in "${stocks[@]}"
do
  curl -s "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$stock&apikey=$key" | \
  jq -r '.[]."05. Price"' | \
  awk -v c=$stock '{print "P",strftime("%Y-%m-%d"),"\""c"\"","₹"$1}' | \
  tee -a $rates_file
  sleep 15s #rate limit to keep the API happy
done

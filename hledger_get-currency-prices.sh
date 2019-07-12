#!/usr/bin/env bash

service="alphavantage"
base_currency="INR"

ledger_dir=~/Accounts
rates_file=$ledger_dir/rates.journal
foreign_file=$ledger_dir/foreignholdings.journal
all_file=$ledger_dir/all.journal
. $ledger_dir/$service-api.key

curl -s https://www.alphavantage.co/physical_currency_list/ | awk -F',' '{print $1}' > /tmp/currency-list
hledger -f $all_file -f $foreign_file stats | grep -E '^Commodities' | grep -o -f /tmp/currency-list > /tmp/valid-currencies
readarray -t foreign_currencies < /tmp/valid-currencies

n=0

if [ $service = "alphavantage" ]
    then
    site="https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=${foreign_currencies[n]}&to_currency=$base_currency&a$
    extract_rate () { jq -r '.[]["5. Exchange Rate"]'; }
elif [ $service = "FIXER" ]
    then
    site="http://data.fixer.io/api/convert?access_key=$key&from=$base_currency&to=${foreign_currencies[n]}&amount=1"
    extract_rate () { jq -r '.result'; }
elif [ $service = "currconv" ]
    then
    site="https://free.currconv.com/api/v7/convert?q=$base_currency_${foreign_currencies[n]}&compact=yes&apiKey=$key"
    extract_rate () { jq -r '.[].val'; }
fi

for foreign_currency in "${foreign_currencies[@]}"
do
  curl -s  $site | \
  extract_rate | \
  awk -v c=$foreign_currency '{print "P",strftime("%Y-%m-%d"),c,"₹"$1}' | \
  tee -a $rates_file
  let "n=n+1"
  sleep 10s #rate limit to keep the API happy
done

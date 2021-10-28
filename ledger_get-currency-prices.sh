#!/usr/bin/env bash

service="currencyscoop"
#service="alphavantage"
#service="currconv"
base_currency="INR"

ledger_dir=~/accounts
rates_file=$ledger_dir/rates_currency.journal
foreign_file=$ledger_dir/foreignholdings.journal
all_file=$ledger_dir/all.journal
. $ledger_dir/scripts/$service-api.key

if [ $service = "alphavantage" ]
 then
 curl -s https://www.alphavantage.co/physical_currency_list/ | awk -F',' '{print $1}' > /tmp/currency-list
elif [ $service = "currencyscoop" ]
 then
 curl -s "https://api.currencyscoop.com/v1/currencies?api_key=${key}" | jq -r '.response.fiats[].currency_code' > /tmp/currency-list
fi

hledger -f $all_file commodities > /tmp/ledger-commodities
readarray -t ledger_commodities < /tmp/ledger-commodities
rm /tmp/ledger-currencies 2> /dev/null

for c in "${ledger_commodities[@]}"
 do
  if [[ "${#c}" == 6 || "${#c}" == 3 ]];
  then echo ${c} | cut -b1-3 | sponge -a /tmp/ledger-currencies;
  fi
done

grep -w -o -f /tmp/currency-list /tmp/ledger-currencies > /tmp/valid-currencies
readarray -t foreign_currencies < /tmp/valid-currencies

for foreign_currency in "${foreign_currencies[@]}"
do
  if [ $service = "alphavantage" ]
    then
    site="https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=${foreign_currency}&to_currency=$base_currency&apikey=$key"
    extract_rate () { jq -r '.[]["5. Exchange Rate"]'; }
    sleep 15s #rate limit to keep the API happy
  elif [ $service = "fixer" ]
    then
    site="http://data.fixer.io/api/convert?access_key=$key&from=$base_currency&to=${foreign_currency}&amount=1"
    extract_rate () { jq -r '.result'; }
  elif [ $service = "currconv" ]
    then
    site="https://free.currconv.com/api/v7/convert?q=${foreign_currency}_${base_currency}&compact=yes&apiKey=$key"
    extract_rate () { jq -r '.results[].val'; }
  elif [ $service = "currencyscoop" ]
    then
    site="https://api.currencyscoop.com/v1/convert?from=${foreign_currency}&to=${base_currency}&amount=1&api_key=${key}"
    extract_rate () { jq -r '.response.value'; }
  fi
  printf "$site\n"
  curl -s $site | \
  extract_rate | \
  awk -v c=$foreign_currency '{print "P",strftime("%Y-%m-%d"),c,"₹"$1}' | \
  sponge -a $rates_file
done
awk ' !x[$0]++' $rates_file | tail -n 10

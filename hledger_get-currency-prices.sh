#!/usr/bin/env bash
#replace "#APIKEY" with the API key, which should look something like "ZCDCI5WLTC3WE2BX"
ALPHAVANTAGE_APIKEY=#APIKEY
BASE_CURRENCY="INR"
FOREIGN_CURRENCIES=("AED" "AZN" "BRL" "CHF" "CLP" "EGP" "EUR" "GBP" "GTQ" "HKD" "IDR" "KES" "LKR" "MAD" "MYR" "PHP" "QAR" "SGD" "THB" "TRY" "USD" "VND" "ZAR")
for FOREIGN_CURRENCY in "${FOREIGN_CURRENCIES[@]}"
do
#  curl -s "https://api.fixer.io/latest?base=$i&symbols=$BASE_CURRENCY" | jq .rates.INR | \
  curl -s "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=$FOREIGN_CURRENCY&to_currency=$BASE_CURRENCY&apikey=$ALPHAVANTAGE_APIKEY" | \
  jq -r '."Realtime Currency Exchange Rate"."5. Exchange Rate"' | \
  awk -v c=$FOREIGN_CURRENCY '{print "P",strftime("%Y-%m-%d"),c,"₹"$1}' | \
  tee -a ~/Accounts/rates.journal
  sleep 10s #rate limit to keep the API happy
done

#!/usr/bin/env bash
CUR=("AED" "AZN" "BRL" "CHF" "CLP" "EGP" "EUR" "GTQ" "HKD" "IDR" "KES" "LKR" "LTL" "MAD" "MYR" "PHP" "QAR" "SGD" "THB" "TRY" "USD" "VND" "ZAR")
for i in {0..22}
do
#  curl -s "https://api.fixer.io/latest?base=${CUR[i]}&symbols=INR" | jq .rates.INR | \
  curl -s "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=${CUR[i]}&to_currency=INR&apikey=[apikey]" | \
  jq -r '."Realtime Currency Exchange Rate"."5. Exchange Rate"' | \
  awk -v c=${CUR[i]} '{print "P",strftime("%Y-%m-%d"),c,"₹"$1}' | \
  tee -a rates.journal
done

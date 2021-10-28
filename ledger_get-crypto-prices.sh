#!/usr/bin/env bash

#service="alphavantage" base_currency="USD" base_symbol="USD "

service="coingecko"
base_currency=("INR" "USD")
base_symbol=("₹" "USD ")
ledger_dir=~/accounts
rates_file=$ledger_dir/rates_crypto.journal
all_file=$ledger_dir/all.journal

if [ $service = "coingecko" ]
  then
  curl -s -X GET "https://api.coingecko.com/api/v3/coins/list" -H "accept: application/json" > /tmp/cryptocurrency-list-coingecko
  jq -r '.[].symbol' /tmp/cryptocurrency-list-coingecko > /tmp/cryptocurrency-list
#  curl -s https://www.alphavantage.co/digital_currency_list/ | awk -F',' '{print $1}' > /tmp/cryptocurrency-list
  else
  . $ledger_dir/scripts/$service-api.key
  curl -s https://www.alphavantage.co/digital_currency_list/ | awk -F',' '{print $1}' > /tmp/cryptocurrency-list
fi

hledger -f $all_file commodities | grep -i -w -f /tmp/cryptocurrency-list | grep -vE '^USD$|LKR|^COP$|THB' > /tmp/valid-cryptocurrencies
readarray -t cryptocurrencies < /tmp/valid-cryptocurrencies
echo ${cryptocurrencies[@]}
echo ${base_symbol[@]}\n
n=0

for bc in "${base_currency[@]}"
  do
  for cryptocurrency in "${cryptocurrencies[@]}"
    do
    if [ $service = "alphavantage" ]
      then
      site="https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=${cryptocurrency}&to_currency=${bc}&apikey=${key}"
      extract_rate () { jq -r '.[]["5. Exchange Rate"]'; }
      sleep 12s #rate limit to keep the API happy
    elif [ $service = "coingecko" ]
      then
      sym=${base_symbol[n]}
      printf "cryptocurrency = ${cryptocurrency,,}\nsym = ${sym}"
      crypto_id=$(jq --arg sym "${cryptocurrency,,}" -r 'last(.[] | select(.symbol==$sym)) | '.id'' /tmp/cryptocurrency-list-coingecko)
       if  [ ${cryptocurrency,,} = "bat" ]
       then
        printf "SYM=bat override"
        crypto_id="basic-attention-token"
       fi
      printf "\ncrypto_id = ${crypto_id}\n"
      site="https://api.coingecko.com/api/v3/simple/price?ids=${crypto_id}&vs_currencies=${bc,,}"
      printf "\n$site\n"
      extract_rate () { jq --arg base "${bc,,}" -r '.[][$base]'; }
    fi
  curl -s $site | \
  extract_rate | \
  awk -v c=$cryptocurrency -v d="${base_symbol[n]}" '{print "P",strftime("%Y-%m-%d"),c,d$1}' | \
  tee -a $rates_file
  done
  let "n=n+1"
  printf "n = $n\n"
done

awk ' !x[$0]++' $rates_file | tail -n 10

#!/usr/bin/env bash
ledger_dir=$HOME/accounts
rates_file=$ledger_dir/rates_gold.journal
gold_type=("916") # it could also be ("916" "999"), for example
gold_symbol=("GOLD916") # it could also be ("GOLD916" "GOLD999"), for example
# 999/995 for 24K, 916 for 22K, 750 for 18K, 585 for 14K
# For both 916 and 999, use gold_type={"999" "916"}

n=0
date=$(date -I)

print_rate() {
  ratedate=$(grep txtRatedate /tmp/ibja_${date}.html \
     | grep -Eo '[0-9]{2}/[0-9]{2}/[0-9]{4}' \
     | awk -F'/' '{print $3"-"$2"-"$1}')
#  ratedate=$(date -I -d "$(grep lbldate /tmp/ibja_${date}.html | cut -d: -f2)")
for gold_type in "${gold_type[@]}"; do
    rate=$(awk "BEGIN {printf \"%.2f\", \
      $(strings /tmp/ibja_${date}.html \
        | sed '/^\s*$/d' \
        | tr -d '[:blank:]' \
        | grep 'Gold$' -A10 \
        | grep -v '<' \
        | grep ${gold_type} -A2 -m1 \
        | tail -n1) \
       / 10}");
    printf "P $ratedate \"${gold_symbol[n]}\" ₹$rate\n" \
      | sponge -a $rates_file
    (( n=n+1 ))
  done
}

if [ -s /tmp/ibja_${date}.html ]; then
#  print_rate
  tail -n 3 $rates_file
  exit
else
  curl "https://ibjarates.com/" --output /tmp/ibja_${date}.html --insecure
  if [ -s /tmp/ibja_${date}.html ]; then
    print_rate
  fi
fi

awk '!dup[$0]++' $rates_file \
  | sponge $rates_file
tail -n 3 $rates_file

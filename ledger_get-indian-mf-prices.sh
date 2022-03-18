#!/usr/bin/env bash
ledger_dir=$HOME/accounts
latest_file=$ledger_dir/latest.journal
rates_file=$ledger_dir/rates_mf.journal
date=$(date -I)

print_rates() {
  grep -f /tmp/ledger-mf-commodities /tmp/NAVAll_${date}.txt \
    | tr -d '\r' \
    | awk -F";" '{printf("\"%s\";%s;%s;",$2,"₹"$5,$4);system("date -d "$6" +%Y-%m-%d")}' \
    | awk -F";" '{print "P",$4,$1,$2 "\t""  ; "$3}' \
    | sponge -a $rates_file
}

deduplicate_rates() {
  awk ' !x[$0]++' $rates_file \
    | sponge $rates_file
}

if type hledger &>/dev/null; then
#   hledger -f $lates_file stats | grep "^Commodities" | grep -o '\bINF\w*' > /tmp/ledger-mf-commodities
#    hledger bal assets --layout=bare -0 -N | awk '{print $2}' | grep -o '\bINF\w*' > /tmp/ledger-mf-commodities
  hledger -f $latest_file commodities | grep '^INF' > /tmp/ledger-mf-commodities
elif type ledger &>/dev/null; then
   ledger -f $latest_file commodities | grep -o '\bINF\w*' > /tmp/ledger-mf-commodities
else
   echo "Neither ledger nor hledger is present"
fi

if [ -s /tmp/NAVAll_${date}.txt ]; then
  tail -n 26 $rates_file
  exit
else
  curl https://www.amfiindia.com/spages/NAVAll.txt -o /tmp/NAVAll_${date}.txt
fi

print_rates
deduplicate_rates
tail -n 26 $rates_file

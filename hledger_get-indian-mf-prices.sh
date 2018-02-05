#!/usr/bin/env bash
curl -s https://www.amfiindia.com/spages/NAVAll.txt | \
grep -E "INF677K01023|[ISIN]|[symbol]" | \
tr -d '\r' | \
awk -F";" '{printf("\"%s\" %s ",$2,"₹"$5);system("date -d "$8" +%Y-%m-%d");}' | \
awk '{print "P",$3,$1,$2 }' | \
tee -a rates.journal

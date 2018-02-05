#!/usr/bin/env bash
sed -i.bak '/^Txn/,$!d' $1
sed -i "s/'//g" $1
sed -i 's/^[ \t]*//' $1
sed -i '/^$/d' $1
sed -i '/^Specified/ d' $1
sed -i '/^Account/ d' $1
sed -i '/^Opening/ d' $1
sed -i '/^Closing/ d' $1
sed -i '1n;/^Txn/d' $1
awk !a[$0]++ $1

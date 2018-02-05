#!/usr/bin/env bash
sed -i.bak '/Sl/,$!d' $1
sed -i '/^Opening/,$d' $1
sed -i 's/"="//g' $1
sed -i 's/\"\"\"/\"/g' $1
awk -i inplace !a[$0]++ $1

#!/bin/bash

# Regev KEX
ts=$(date +%s%N)

echo "Regev KEX (not recommended to use, result key may not match):"
sage Regev.sage

tt=$((($(date +%s%N) - $ts)/1000000))
echo "Time taken in milliseconds: $tt"
echo


# Ding KEX
ts=$(date +%s%N)

echo "Ding KEX (not recommended to use, resulting key is biased):"
sage Ding.sage

tt=$((($(date +%s%N) - $ts)/1000000))
echo "Time taken in milliseconds: $tt"
echo


# Peikert KEX
ts=$(date +%s%N)

echo -e "Peikert KEX (recommended to use, easy to implement):"
sage Peikert.sage

tt=$((($(date +%s%N) - $ts)/1000000))
echo "Time taken in milliseconds: $tt"
echo


# NewHope KEX
ts=$(date +%s%N)

echo -e "NewHope KEX (recommended to use but difficult to implement):"
sage NewHope.sage

tt=$((($(date +%s%N) - $ts)/1000000))
echo "Time taken in milliseconds: $tt"
echo


# clean up
rm *.py


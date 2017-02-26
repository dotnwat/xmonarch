#!/bin/bash

set -e

function compare() {
  local size=$1
  local func=$2

  local input=$(mktemp)
  local out0=$(mktemp)
  local out1=$(mktemp)
  trap "rm -f $input $out0 $out1" EXIT

  cat /dev/urandom | head -c $size | base64 > $input
  cat $input | ./hash_test $func > $out0
  cat $input | node hash_test.js $func > $out1

  diff $out0 $out1

  rm $input $out0 $out1
}

for optlevel in "" -O0 -O1 -O2 -O3; do
  make clean
  make OPT_LEVEL=$optlevel
  for size in 1 2 3 32 38 99 100 12000 39833; do
    compare $size keccak
    compare $size jh
  done
done

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
  cat $input | md5sum
  cat $input | ./hash_test $func > $out0
  cat $input | node hash_test.js $func > $out1

  diff $out0 $out1
  cat $out0 | md5sum

  rm $input $out0 $out1
}

for optlevel in "" -O0 -O1 -O2 -O3; do
  make clean
  make OPT_LEVEL=$optlevel -j$(nproc)
  for run in {1..100}; do
    size=$((1 + RANDOM % 1000000))
    for algo in keccak keccakf jh blake skein groestl; do
      echo "run=$run opt-level=\"$OPT_LEVEL\" size=$size algo=$algo"
      compare $size $algo
    done
    echo "run=$run opt-level=\"$OPT_LEVEL\" size=200 algo=oaes_key_omport_data"
    compare 200 oaes_key_import_data # needs 200 bytes
  done
done

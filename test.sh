#!/bin/bash

set -e
set -x

PATH=$PWD:$PATH

function compare() {
  local size=$1
  local prog0=$2
  local prog1=$3

  local input=$(mktemp)
  local out0=$(mktemp)
  local out1=$(mktemp)
  trap "rm -f $input $out0 $out1" EXIT

  cat /dev/urandom | head -c $size | base64 > $input
  cat $input | $prog0 > $out0
  cat $input | $prog1 > $out1

  diff $out0 $out1

  rm $input $out0 $out1
}

for size in 1 2 3 32 38 99 100 12000 39833; do
  compare $size test_keccak "node test_keccak.js"
done

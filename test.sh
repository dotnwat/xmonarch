#!/bin/bash

set -e

: ${OPT_LEVEL:=""}

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

function build_and_run() {
  make clean
  make -j$(nproc)
  for run in {1..10}; do
    size1=$((1 + RANDOM % 128))
    size2=$((129 + RANDOM % 1000000))
    for size in 10 $size1 $size2 39; do
      for algo in keccak jh blake skein groestl; do
        echo "run=$run opt-level=\"$OPT_LEVEL\" size=$size algo=$algo"
        compare $size $algo
      done
      echo "run=$run opt-level=\"$OPT_LEVEL\" size=200 algo=oaes_key_omport_data"
      compare 200 oaes_key_import_data
      echo "run=$run opt-level=\"$OPT_LEVEL\" size=200 algo=keccakf"
      compare 200 keccakf
    done
  done
  for vecfile in blake groestl/groestl jh keccak/keccak keccak/keccakf oaes_key_import_data skein/skein cryptonight; do
    echo "testing $vecfile vectors"
    cat ${vecfile}.json | ./hash_test2
    cat ${vecfile}.json | node hash_test2.js
  done
}

build_and_run

#!/bin/bash

echo "Fapolicyd Benchmark"

TMPSINGLE=`mktemp`
TMPMULTIPLE=`mktemp`

echo
echo "Running single exec measurement - one binary"

for i in `seq 1 2`;
do
    ./benchmark-single-exec.sh one-binary | grep -B1 Result | tee $TMPSINGLE;
done

echo
echo "Running single exec measurement - multiple binaries"

for i in `seq 1 2`;
do
    ./benchmark-single-exec.sh multiple-binary| grep -B1 Result | tee $TMPMULTIPLE;
done

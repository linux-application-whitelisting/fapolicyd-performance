#!/bin/bash

echo "Fapolicyd Benchmark"

TMPSINGLE=`mktemp`
TMPMULTIPLE=`mktemp`
ITERATIONS=$1

echo
echo "Running single exec measurement - one binary"

#for i in `seq 1 2`;
#do
    bash ./benchmark-single-exec.sh one-binary $ITERATIONS | grep -B1 Result | tee $TMPSINGLE
#done

echo
echo "Running single exec measurement - multiple binaries"

#for i in `seq 1 2`;
#do
    bash ./benchmark-multiple-exec.sh multiple-binary $ITERATIONS | grep -B1 Result | tee $TMPMULTIPLE
#done

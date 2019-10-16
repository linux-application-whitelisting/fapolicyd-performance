#!/bin/bash

# Usage: ./benchmark-open-database.sh <xtimes> <path/to/test_makedirectory>

ITERATIONS=$1
FILES="${@:2}"
TMPFILE=$(mktemp)
TMPDIR=$(mktemp -d)

make

echo
echo "Test1: Database WITHOUT reversed keys"
echo > $TMPFILE
./read-database $TMPDIR 0 $ITERATIONS $FILES 1>$TMPFILE 2>/dev/null
awk '{sum+=$1} END { print "Time = ",sum }' $TMPFILE

echo
echo "Test2: Database WITH reversed keys"
echo > $TMPFILE
rm -rf $TMPDIR && mkdir $TMPDIR
./read-database $TMPDIR 1 $ITERATIONS $FILES 1>$TMPFILE 2>/dev/null
awk '{sum+=$1} END { print "Time = ",sum }' $TMPFILE

rm -rf $TMPFILE $TMPDIR

echo

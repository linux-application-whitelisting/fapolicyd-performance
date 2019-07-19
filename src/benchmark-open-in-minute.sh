#!/bin/bash


TMPFILE=$(mktemp)
TMPDIR=$(mktemp -d)

#set -x

BINARY=$1
FILESNUM=$2

BINPREFIX="$TMPDIR/bin"


for i in `seq $FILESNUM`;
do
    touch "$BINPREFIX$i"
done

echo
echo "Test 5: as much opens as possible in minute - without fapolicyd"

systemctl stop fapolicyd
echo "Waiting for daemon to stop"
sleep 5
systemctl status fapolicyd --no-pager
echo "Removing db"
rm -rf /var/lib/fapolicyd/*
rm -rf /var/run/fapolicyd/*

RESULT=""
for i in `seq 3`;
do
    echo "Measure"
    RESULT="$RESULT `./$BINARY $BINPREFIX $FILESNUM | head -n 1`";
done

echo $RESULT > $TMPFILE
AVG=`awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' $TMPFILE`

echo
cat $TMPFILE
echo > $TMPFILE


echo "Running binary that is looping on open() withou fapolicyd $FAPOLICYD."
echo "Result: $AVG"

echo
echo "Test 6: as much opens as possible in minute - with fapolicyd"

echo "Removing db"
rm -rf /var/lib/fapolicyd/*
rm -rf /var/run/fapolicyd/*

systemctl start fapolicyd
echo "Waiting for daemon to start"
sleep 10
systemctl status fapolicyd --no-pager


RESULT=""
for i in `seq 3`;
do
    echo "Measure"
    RESULT="$RESULT `./$BINARY $BINPREFIX $FILESNUM | head -n 1`";
done

echo $RESULT > $TMPFILE
AVG=`awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' $TMPFILE`

echo
cat $TMPFILE
echo > $TMPFILE



echo "Running binary that is looping on open() with fapolicyd $FAPOLICYD."
echo "Result: $AVG"


# Cleanup


echo "CLEANUP"
systemctl stop fapolicyd
echo "Waiting for daemon to stop"
sleep 5
systemctl status fapolicyd --no-pager
echo "Removing db"
rm -rf /var/lib/fapolicyd/*
rm -rf /var/run/fapolicyd/*
rm -rf $TMPFILE
rm -rf $TMPDIR

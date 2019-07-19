#!/bin/bash


TMPFILE=$(mktemp)
TMPDIR=$(mktemp -d)

#set -x

BINARY=$1
ITERATIONS=$2

BINPREFIX="$TMPDIR/bin"


for i in `seq $ITERATIONS`;
do
    cp ./$BINARY "$BINPREFIX$i"
done

#exit

echo
echo "Test1: $BINARY without fapolicyd"

systemctl stop fapolicyd
echo "Waiting for daemon to stop"
sleep 5
systemctl status fapolicyd --no-pager
echo "Removing db"
rm -rf /var/lib/fapolicyd/*
rm -rf /var/run/fapolicyd/*

strace -e execve -T -f ./$BINARY $ITERATIONS $BINPREFIX 2>$TMPFILE 1>/dev/null
#cat $TMPFILE
RESULTS=`grep execve $TMPFILE | tail -n $ITERATIONS | sed -E 's/\[.*\] //g' | cut -d' ' -f6 | cut -d'<' -f2 | cut -d'>' -f1`
echo $RESULTS > $TMPFILE
AVG=` awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' $TMPFILE`

cat $TMPFILE
echo > $TMPFILE
echo "Running same binary for $ITERATIONS iterations without fapolicyd $FAPOLICYD."
echo "Result: $AVG"


echo
echo "Test2: $BINARY with fapolicyd"

echo "Removing db"
rm -rf /var/lib/fapolicyd/*
rm -rf /var/run/fapolicyd/*

systemctl start fapolicyd
echo "Waiting for daemon to start"
sleep 10
systemctl status fapolicyd --no-pager

strace -e execve -T -f ./$BINARY $ITERATIONS $BINPREFIX 2>$TMPFILE 1>/dev/null
#cat $TMPFILE
RESULTS=`grep execve $TMPFILE | tail -n $ITERATIONS | sed -E 's/\[.*\] //g' | cut -d' ' -f6 | cut -d'<' -f2 | cut -d'>' -f1`
echo $RESULTS > $TMPFILE
AVG=` awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' $TMPFILE`

cat $TMPFILE
echo > $TMPFILE
echo "Running same binary for $ITERATIONS iterations with fapolicyd $FAPOLICYD."
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

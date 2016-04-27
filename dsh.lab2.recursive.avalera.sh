#!/bin/bash

ASG="lab2"
DFILE=".d.recursive.f"
STUDENT=$(basename $(pwd))

# rm -rf $DFILE
if [[ ! -e $DFILE ]]; then
	
	JAVASRC="FileReverse.java"
	if [[ ! -e $JAVASRC ]]; then
		JAVASRC=$(ls *.java | head -1)
	fi
	
	for i in $(seq 1 10); do echo; done
	grep -P 'String\sstringReverse' -A 10 $JAVASRC
	for i in $(seq 1 5); do echo; done
	echo -n "Is stringReverse() written recursively: "
	read INPUT
	if [[ $INPUT == y ]]; then
		echo "5 / 5 | stringReverse() written purely recursively" >> $DFILE
	elif [[ $INPUT == n ]]; then
		echo "0 / 5 | stringReverse() not or only partially recursive" >> $DFILE
	else
		echo "Skipped submission for now"
	fi
fi

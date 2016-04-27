#!/bin/bash
# CLASS cmps012b-pt.s16
# ASG lab2
# USER avalera

ASG="lab2"
DFILE=".d.recursive.f"
STUDENT=$(basename $(pwd))

# rm -rf $DFILE
if [[ ! -e $DFILE ]]; then

	echo "Grading $STUDENT"

	JAVASRC="FileReverse.java"
	if [[ ! -e $JAVASRC ]]; then
		JAVASRC=$(ls *.java | head -1)
	fi

	for i in $(seq 1 10); do echo; done
	if [[ -e .d.design.f ]]; then cat .d.design.f; fi
	for i in $(seq 1 5); do echo; done
	if ! grep -P 'String\sstringReverse' -A 15 $JAVASRC; then
		cat $JAVASRC
		echo "FUNCTION RECOGNITION FAILED. SCROLL UP TO MANUALLY FIND IT."
	fi
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
else
	echo -n "$STUDENT "
	cat $DFILE
fi

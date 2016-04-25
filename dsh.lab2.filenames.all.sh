#!/bin/bash

ASG="lab2"
DFILE=".d.filenames.f"

rm -f $DFILE
SCORE=3
for FILE in *; do
	if [[ $FILE == *everse* ]]; then
		if [[ ! -e FileReverse.java ]]; then
			echo "0 / 1 | Incorrect filename ($FILE -> FileReverse.java)" >> $DFILE
			SCORE=$((SCORE - 1))
		fi
	elif [[ $FILE == *README* ]]; then
		if [[ ! -e README ]]; then
			echo "0 / 1 | Incorrect filename ($FILE -> README)" >> $DFILE
			SCORE=$((SCORE - 1))
		fi
	elif [[ $FILE == *ake* ]]; then
		if [[ ! -e Makefile ]]; then
			echo "0 / 1 | Incorrect filename ($FILE -> Makefile)" >> $DFILE
			SCORE=$((SCORE - 1))
		fi
	else
		echo "X / X | Extra file submitted ($FILE)" >> $DFILE
	fi
done
if [[ $SCORE -gt 0 ]]; then
	echo "$SCORE / $SCORE | Correct filename" >> $DFILE
fi

#!/bin/bash

ASG="lab2"
DFILE=".d.comments.f"
STUDENT=$(basename $(pwd))

rm -rf $DFILE

checkcomment() {
	if [[ -e $1 ]]; then
		if [[ ! $(head -c 1 $1) == "$2" ]]; then
			echo "0 / X | Missing comment block ($1)" >> $DFILE
		fi
		if ! grep -qP "$STUDENT" $1; then
			echo "0 / X | Missing username identifier ($1)" >> $DFILE
		fi
	fi
}
checkcomment FileReverse.java "/"
checkcomment Makefile "#"

if [[ -e README ]]; then
	if ! grep -qP "$STUDENT" README; then
		echo "0 / X | Missing username identifier (README)" >> $DFILE
	fi
	for FILE in FileReverse.java Makefile README; do
		if ! grep -qP "$FILE" README; then
			echo "0 / X | README missing reference to file ($FILE)" >> $DFILE
		fi
	done
fi

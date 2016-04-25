#!/bin/bash

ASG="lab2"
DFILE=".d.make.f"
BACKUP=".backup"

rm -rf $DFILE $BACKUP/
mkdir $BACKUP
cp * $BACKUP

JAVASRC=""
for FILE in *; do
	if [[ $FILE == *everse* ]]; then
		if [[ ! -e FileReverse.java ]]; then
			JAVASRC=$FILE
		else
			JAVASRC=FileReverse.java
		fi
	fi
done
echo "$JAVASRC"

if [[ -e Makefile ]]; then
	echo "5 / 5 | Makefile exists" >> $DFILE
else 
	echo "0 / 5 | No Makefile (ls: $(ls -m))" >> $DFILE
fi

cd $BACKUP
for FILE in *; do
	if [[ ! -e ../$FILE ]]; then
		echo "X / X | WARNING! Your Makefile deletes $FILE" >> $DFILE
		cp $FILE ..
	fi
done

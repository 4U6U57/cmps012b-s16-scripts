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
EXESRC=${JAVASRC//.java/}

if make -s $EXESRC; then
	echo "3 / 3 | Makefile makes correctly" >> $DFILE
else
	echo "1 / 3 | Makefile make fails" >> $DFILE
fi

if [[ -e $EXESRC ]]; then
	echo "1 / 1 | Executable created correctly" >> $DFILE
else
	echo "0 / 1 | Executable not created (ls: $(ls -m))" >> $DFILE
fi

make -s clean

if [[ -e $EXESRC || -e *.class || -e Manifest ]]; then
	echo "0 / 1 | Clean target faulty (ls: $(ls -m))" >> $DFILE
	rm -rf Manifest *.class $EXESRC
else
	echo "1 / 1 | Clean target works correctly" >> $DFILE
fi

cd $BACKUP
for FILE in *; do
	if [[ ! -e ../$FILE ]]; then
		echo "X / X | WARNING! Your Makefile deletes $FILE, very bad" >> $DFILE
		cp $FILE ..
	fi
done

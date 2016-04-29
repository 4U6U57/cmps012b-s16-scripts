#!/bin/bash
# CLASS cmps012b-pt.s16
# ASG lab2
# USER all

ASG="lab2"
DFILE=".d.make.f"
BACKUP=".backup"

# rm -f $DFILE # uncomment to run make everytime
if [[ ! -e $DFILE ]]; then
	rm -rf $BACKUP/
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

	make -s $EXESRC

	if [[ -e $EXESRC ]]; then
		echo "1 / 1 | Executable created correctly" >> $DFILE
	else
		echo "0 / 1 | Executable not created (ls: $(ls -m))" >> $DFILE
		echo "This is a temporary class file, meant to test make clean" > $EXESRC.class
	fi

	make -s clean

	if [[ -e $EXESRC || -e *.class || -e Manifest ]]; then
		echo "0 / 1 | Clean target doesn't clean (ls: $(ls -m))" >> $DFILE
	else
		echo "1 / 1 | Clean target works correctly" >> $DFILE
	fi

	cd $BACKUP
	for FILE in *; do
		if [[ ! -e ../$FILE ]]; then
			echo "0 / X | Clean target deletes source code ($FILE)" >> ../$DFILE
			cp $FILE ..
		fi
	done

	rm -rf Manifest *.class $EXESRC
fi

#!/bin/bash

ASG="lab2"
DFILE=".d.make.f"

rm -f $DFILE
if [[ -e Makefile ]]; then
	echo "5 / 5 | Makefile exists" >> $DFILE
else 
	echo "0 / 5 | No Makefile" >> $DFILE
fi

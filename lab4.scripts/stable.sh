#!/bin/bash

GRADEFILE="grade.txt"
PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLASSDIR="$(echo $PWD | cut -d '/' -f 1-5)"
CLASS="$(basename $CLASSDIR)"
ASG="$(basename $PWD)"
ASGBIN="$CLASSDIR/bin/$ASG"
ASGDIR="$CLASSDIR/$ASG"
ASGTABLE="$ASGBIN/student"
SEPARATE="=================================================="

forall() {
   CLASSNUM=$(echo $CLASS | cut -d '0' -f 2 | cut -d '-' -f 1)
   cd $ASGDIR
   for STUDENT in $(ls -d */); do
      STUDENTDIR=$ASGDIR/$STUDENT
      STUDENT=$(basename $STUDENT /)
      cd $STUDENTDIR
      #echo "$SEPARATE"
      #pwd
      $@
   done
}

declare -A STUDENTTABLE
readtable() {
   TABLEFILE=$ASGTABLE/student_$STUDENT.autotable
   cleartable
   while read LINE; do
      STUDENTTABLE["$(echo $LINE | cut -d ':' -f 1)"]="$(echo $LINE | cut -d ':' -f 2-)"
   done < $1
}
writetable() {
   rm -f $1
   for KEY in ${!STUDENTTABLE[@]}; do
      echo $KEY: ${STUDENTTABLE["$KEY"]} >> $1
   done
}
cleartable() {
   for KEY in ${!STUDENTTABLE[@]}; do
      unset STUDENTTABLE["$KEY"]
   done
}

backup() {
   if [[ ! -e $1 ]]; then
      mkdir $1
   fi
   for FILE in *; do
      cp -n $FILE $1/$FILE
   done
}
restore() {
   for FILE in *; do
      if [[ ! -e $1/$FILE ]]; then
         echo "RESTORE: $FILE created during grading, deleting"
         rm -f $FILE
      fi
   done
   for FILE in $1/*; do
      FILE=$(basename $FILE)
      if [[ ! -e $FILE ]]; then
         echo "RESTORE: $FILE deleted during grading, restoring"
         cp $1/$FILE $FILE
      elif ! diff -q $FILE $1/$FILE; then
         echo "RESTORE: $FILE modified during grading, restoring"
         cp $1/$FILE $FILE
      fi
   done
}

checkfilename() {
   FILE=$1
   REGEX=$2
   if [[ -e $FILE ]]; then
      echo "$FILE"
   else
      #echo "ls: $(ls -m)"
      MATCHES=( $REGEX )
      if [[ -e ${MATCHES[0]} ]]; then
         echo "${MATCHES[0]}->$FILE"
      else
         echo "$FILE(?)"
      fi
   fi
}
declare -A FILES
FILES=( [Makefile]=*ake* [README]=README* [charType.c]=*ype* )
grade() {
   # Actual grading code here
   for FILE in ${!FILES[@]}; do
      echo -n "  " #remove
      CHECK=$(checkfilename $FILE ${FILES[$FILE]})
      if [[ $CHECK == $FILE ]]; then
         echo "$FILE submitted correctly"
      elif echo $CHECK | grep -qP "\-\>"; then
         echo "$FILE named incorrectly ($CHECK)"
      else
         echo "$FILE missing (ls: $(ls -m))"
      fi
   done
}
main() {
   BACKUP=".backup"
   pwd
   backup $BACKUP
   readtable $ASGTABLE/student_$STUDENT.autotable
   grade
   restore $BACKUP
   writetable $ASGTABLE/.student_$STUDENT.autotable.swp
   cleartable
}
forall main

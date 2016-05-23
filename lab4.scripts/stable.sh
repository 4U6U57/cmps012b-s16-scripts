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
         rm -f ./$FILE
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
declare -A NUMBERS
FILES=( [Makefile]=*ake* [README]=R* [charType.c]=*ype* )
NUMBERS=( [Makefile]=5 [README]=6 [charType.c]=7 )
grade() {
   # Actual grading code here
   for FILE in ${!FILES[@]}; do
      CHECK=$(checkfilename $FILE ${FILES[$FILE]})
      if [[ $CHECK == $FILE ]]; then
         STUDENTTABLE[grade.${NUMBERS[$FILE]}]=P
         STUDENTTABLE[notes.${NUMBERS[$FILE]}]="$FILE submitted correctly"
      elif echo $CHECK | grep -qP "\-\>"; then
         STUDENTTABLE[grade.${NUMBERS[$FILE]}]=C
         STUDENTTABLE[notes.${NUMBERS[$FILE]}]="$FILE named incorrectly ($CHECK)"
      else
         STUDENTTABLE[grade.${NUMBERS[$FILE]}]=C
         STUDENTTABLE[notes.${NUMBERS[$FILE]}]="$FILE missing (ls: $(ls -m))"
      fi
      if [[ $FILE == charType.c ]]; then
         EXE=$(basename $(echo $CHECK | cut -d '>' -f 2) .c)
      fi
   done

   if echo $EXE | grep -qP "\?"; then
      STUDENTTABLE[grade.8]=0
      STUDENTTABLE[notes.8]="No source code to check leaks (ls: $(ls -m))"
   else
      bash -c "make" > /dev/null 2>&1
      if [[ ! -e $EXE ]]; then
         ALTEXE=( char FileReverse charTypE )
         for ALT in $ALTEXE; do
            if [[ -e $ALT ]]; then
               EXE=$ALT
            fi
         done
      fi
      if [[ -e $EXE ]]; then
         LEAKS=$(valgrind --log-fd=1 $EXE charType.c | grep -P "in use at exit")
         if [[ $(echo $LEAKS | cut -d ":" -f 2 | cut -d " " -f 2) == 0 ]]; then
            STUDENTTABLE[grade.8]=P
            STUDENTTABLE[notes.8]="Program ran without leaks"
         else
            STUDENTTABLE[grade.8]=C
            STUDENTTABLE[notes.8]="Program ran with leaks (valgrind: $LEAKS)"
         fi
      else
         STUDENTTABLE[grade.8]=P
         STUDENTTABLE[notes.8]="No exe to check leaks (ls: $(ls -m))"
      fi
      rm -f $EXE *.o
   fi
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

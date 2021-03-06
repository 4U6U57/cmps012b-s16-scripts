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
ALTEXE="char FileReverse charTypE ./-std\=c99"
grade() {
   # Actual grading code here

   # Filenames (#5-7)
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
      elif [[ $FILE == Makefile ]]; then
         MAKE=$(echo $CHECK | cut -d '>' -f 2)
      fi
   done

   # Makefile (#3)
   MAKESCORE=2
   MAKEMSG=""
   if echo $EXE | grep -qP "\?"; then
      MAKEMSG="No source code to check make"
   else
      bash -c "make" > /dev/null 2>&1
      if [[ ! -e $EXE ]]; then
         for ALT in $ALTEXE; do
            if [[ -e $ALT ]]; then
               EXE=$ALT
            fi
         done
      fi
      if [[ -e $EXE ]]; then
         MAKEMSG+="Makefile compiled executable"
      else
         MAKESCORE=$(($MAKESCORE - 1))
         MAKEMSG+="Makefile did not compile executable"
         echo "PLACEHOLDER EXECUTABLE" > $EXE
      fi
      bash -c "make clean" > /dev/null 2>&1
      if [[ ! -e $EXE ]]; then
         MAKEMSG+=", cleaned properly"
      else
         MAKESCORE=$(($MAKESCORE - 1))
         MAKEMSG+=", did not clean"
         rm -f $EXE
      fi
      for FILE in $BACKUP/*; do
         FILE=$(basename $FILE)
         if [[ ! -e $FILE ]]; then
            cp $BACKUP/$FILE $FILE
            MAKESCORE=$(($MAKESCORE - 1))
            MAKEMSG+=", deleted $FILE"
         elif ! diff -q $FILE $BACKUP/$FILE; then
            cp $BACKUP/$FILE $FILE
            MAKESCORE=$(($MAKESCORE - 1))
            MAKEMSG+=", edited source file $FILE"
         fi
      done
      if [[ $MAKESCORE -lt 0 ]]; then
         MAKESCORE=0
      fi
   fi
   STUDENTTABLE[grade.3]=$MAKESCORE
   STUDENTTABLE[notes.3]="$MAKEMSG"

   # Valgrind (#8)
   if echo $EXE | grep -qP "\?"; then
      STUDENTTABLE[grade.8]=0
      STUDENTTABLE[notes.8]="No source code to check leaks (ls: $(ls -m))"
   else
      bash -c "make" > /dev/null 2>&1
      if [[ ! -e $EXE ]]; then
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
         STUDENTTABLE[notes.8]="No executable to check leaks (ls: $(ls -m))"
      fi
   fi

   # Performance (#2)
   if [[ ! -e $EXE ]]; then
      STUDENTTABLE[grade.2]=C
      STUDENTTABLE[notes.2]="No executable to check diff (ls: $(ls -m))"
   else
      ./$EXE $ASGBIN/in out > /dev/null 1>&2
      DIFF=$((5 - ($(diff -iwB out $ASGBIN/out | grep "^>" | wc -l) / 4)))
      if [[ $DIFF -le 1 ]]; then
         DIFF=C
      fi
      if [[ $DIFF == 5 ]]; then
         STUDENTTABLE[grade.2]=P
         STUDENTTABLE[notes.2]="Program passed diff test"
      else
         STUDENTTABLE[grade.2]=$DIFF
         DIFF=$(diff -iwb out $ASGBIN/out | grep -Pv "^<|^>|^-" | tr '\n' ' ' | head -c -1)
         STUDENTTABLE[notes.2]="Program failed diff (diff: $DIFF)"
      fi
   fi

   rm -f $EXE *.o out
}
main() {
   BACKUP=".backup"
   pwd
   backup $BACKUP
   readtable $ASGTABLE/student_$STUDENT.autotable
   grade
   restore $BACKUP
   #writetable $ASGTABLE/.student_$STUDENT.autotable.swp
   writetable $ASGTABLE/student_$STUDENT.autotable
   cleartable
}
forall main

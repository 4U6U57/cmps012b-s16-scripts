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
   cleartable
   if [[ -e $1 ]]; then
      while read LINE; do
         STUDENTTABLE["$(echo $LINE | cut -d ':' -f 1)"]="$(echo $LINE | cut -d ':' -f 2-)"
      done < $1
   else
      echo "TABLE: $STUDENT does not have a table"
   fi
}
writetable() {
   rm -f $1
   for KEY in ${!STUDENTTABLE[@]}; do
      echo $KEY: ${STUDENTTABLE["$KEY"]} >> $1
   done
   cat $1 | sort > $1.swp
   mv $1.swp $1
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
      elif ! diff -q $FILE $1/$FILE > /dev/null; then
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
FILES=( [List.java]=*ist.* [Makefile]=*ake* [ListTest.java]=*est* )
NUMBERS=( [List.java]=5 [Makefile]=6 [ListTest.java]=7 )
ALTEXE=""
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

      if [[ $FILE == List.java ]]; then
         EXE=$(basename $(echo $CHECK | cut -d '>' -f 2) .c)
      elif [[ $FILE == Makefile ]]; then
         MAKE=$(echo $CHECK | cut -d '>' -f 2)
      fi
   done

   # Comment Block (#4)
   SCORE=P
   MSG="Comment block checks: \n"
   for FILE in ${!FILES[@]}; do
      if [[ ! -e $FILE ]]; then
         MSG+=" MISSING file $FILE, cannot check comment\n"
      else
         if [[ $FILE =~ .*.java ]]; then
            COMMENT=/
         else
            COMMENT=\#
         fi
         if [[ $(head -c 1 $FILE) == $COMMENT ]]; then
            MSG+=" FOUND $FILE comment block\n"
         else
            FIRST=$(head -c 1 $FILE)
            MSG+=" MISSING $FILE comment block (${FIRST//\n/\\n})\n"
            SCORE=C
         fi
      fi
   done
   MSG+="Username identifier checks: \n"
   for FILE in ${!FILES[@]}; do
      if [[ ! -e $FILE ]]; then
         MSG+=" MISSING file $FILE, cannot check username identifier\n"
      else
         if ! head -n 5 $FILE | grep -qP "$STUDENT"; then
            MSG+=" MISSING $FILE comment block indentifier\n"
         else
            MSG+=" FOUND $FILE comment block indentifier\n"
         fi
      fi
   done
   STUDENTTABLE[grade.4]=$SCORE
   STUDENTTABLE[notes.4]="$MSG"

   # Interface testing (#9)
   SCORE=2
   DEPS=( ListInterface.java ListIndexOutOfBoundsException.java ListClient.java )
   MSG="Dependency checks: \n"
   CHECK=0
   for FILE in ${DEPS[@]}; do
      if [[ ! -e $FILE ]]; then
         cp $ASGBIN/$FILE .
         MSG+=" MISSING dependency $FILE\n"
         CHECK=$((CHECK + 3))
      elif ! diff -q $FILE $ASGBIN/$FILE > /dev/null; then
         cp $ASGBIN/$FILE .
         MSG+=" MODIFIED dependency $FILE\n"
         CHECK=$((CHECK + 1))
      else
         MSG+=" FOUND dependency $FILE\n"
      fi
   done
   if [[ $CHECK -gt 2 ]]; then
      SCORE=$(($SCORE - 1))
   fi

   INTER="public\s*class\s*List<T>\s*implements\s*ListInterface<T>"
   FUNCS=( "public boolean isEmpty()" "public int size()" "public T get(int index) throws ListIndexOutOfBoundsException" "public void add(int index, T newItem) throws ListIndexOutOfBoundsException" "public void remove(int index) throws ListIndexOutOfBoundsException" "public void removeAll()" )
   CHECK=0
   MSG+="Interface checks: \n"
   if [[ ! -e List.java ]]; then
      MSG+=" MISSING source code List.java, cannot check interface\n"
   elif grep "$INTER" List.java > /dev/null; then
      MSG+=" FOUND implements statement\n"
      for FUNC in "${FUNCS[@]}"; do
         FUNCREGEX=${FUNC// /\\s*}
         FUNCREGEX=${FUNCREGEX//index/.*}
         FUNCREGEX=${FUNCREGEX//newItem/.*}

         if grep "$FUNCREGEX" List.java > /dev/null; then
            MSG+=" FOUND function $FUNC\n"
         else
            MSG+=" MODIFIED function $FUNC\n"
            CHECK=$(($CHECK + 1))
         fi
      done
      if [[ $CHECK -gt 2 ]]; then
         SCORE=$(($SCORE - 1))
      fi

      if [[ $SCORE -eq 2 ]]; then
         SCORE=P
      elif [[ $SCORE -eq 0 ]]; then
         SCORE=C
      fi
   else
      MSG+=" MISSING implements statement in List.java, cannot check functions\n"
   fi
   STUDENTTABLE[grade.9]=$SCORE
   STUDENTTABLE[notes.9]="$MSG"

   # Makefile (#3)
   SCORE=2
   MSG="Makefile checks: \n"
   EXE="ListClient"
   ALTS=( List ListTest )
   touch out
   if [[ ! -e List.java ]]; then
      MSG+=" MISSING source code, cannot check make\n"
   else
      bash -c "make $EXE" > /dev/null 2>&1
      if [[ -e $EXE ]]; then
         chmod +x $EXE
         MSG+=" COMPILED $EXE successfully\n"
         $EXE > out
      else
         bash -c "make" > /dev/null 2>&1

         for ALT in ${ALTS[@]}; do
            if [[ -e $ALT ]]; then
               EXE=$ALT
            fi
         done

         if [[ -e $EXE ]]; then
            chmod +x $EXE
            MSG+=" COMPILED $EXE successfully\n"
            $EXE > out
         else
            SCORE=$(($SCORE - 1))
            MSG+=" MISSING $EXE, was not compiled by Makefile (ls: $(ls -m))\n"

            cp $ASGBIN/Makefile makefile
            bash -c "make $EXE" > /dev/null 2>&1

            if [[ -e $EXE ]]; then
               $EXE > out
            else
               echo "PLACEHOLDER EXECUTABLE" > $EXE
            fi
         fi
      fi
      bash -c "make clean" > /dev/null 2>&1
      if [[ ! -e $EXE ]]; then
         MSG+=" CLEANED $EXE sucessfully\n"
      else
         SCORE=$(($SCORE - 1))
         MSG+=" MISSING clean statement, $EXE still exists (ls: $(ls -m))\n"
         rm -f $EXE
      fi
      for FILE in ${!FILES[@]}; do
         if [[ -e $BACKUP/$FILE ]]; then
            if [[ ! -e $FILE ]]; then
               cp $BACKUP/$FILE $FILE
               SCORE=$(($SCORE - 1))
               MSG+=" MISSING file $FILE, deleted by Makefile\n"
            elif ! diff -q $FILE $BACKUP/$FILE > /dev/null; then
               cp $BACKUP/$FILE $FILE
               SCORE=$(($SCORE - 1))
               MSG+=" MODIFIED file $FILE, corrupted by Makefile\n"
            fi
         fi
      done
   fi
   if [[ $SCORE -lt 0 ]]; then
      SCORE=C
   elif [[ $SCORE -eq 2 ]]; then
      SCORE=P
   fi
   STUDENTTABLE[grade.3]=$SCORE
   STUDENTTABLE[notes.3]="$MSG"

   # Performance (#2)
   SCORE=5
   MSG="Performance checks: \n"
   SCORE=$(($SCORE - ($(diff -iwB out $ASGBIN/model-out | grep "^>" | wc -l) / 4)))
   if [[ $SCORE -le 1 ]]; then
      SCORE=C
   fi
   if [[ $SCORE == 5 ]]; then
      SCORE=P
      MSG+=" PASSED diff test with model-out\n"
   else
      DIFF=$(diff -iwb out $ASGBIN/model-out | grep -Pv "^<|^>|^-" | tr '\n' ' ' | head -c -1)
      MSG+=" FAILED diff test (diff: $DIFF)\n"
   fi
   STUDENTTABLE[grade.2]=$SCORE
   STUDENTTABLE[notes.2]="$MSG"

   rm -f $EXE *.class out
}

main() {
   BACKUP=".backup"
   pwd
   backup $BACKUP
   readtable $ASGTABLE/student_$STUDENT.autotable
   grade
   restore $BACKUP
   # writetable $ASGTABLE/temp_$STUDENT.autotable # Comment this one out
   writetable $ASGTABLE/student_$STUDENT.autotable # Uncomment to deploy
   cleartable
}
forall main

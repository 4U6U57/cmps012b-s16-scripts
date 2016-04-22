BINPATH = ..

select:
	echo Please select a valid make target

lab2:
	gcc -c -Wall -Werror --std=c99 $@.c
	gcc -o $@ $@.o -lm
	rm -f $@.o
	mv $@ ${BINPATH}/$@



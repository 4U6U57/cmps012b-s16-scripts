BINPATH = ..

select :
	echo Please select a valid make target

lab% : lab%.c
	gcc -c -Wall -Werror --std=c99 $@.c
	gcc -o $@ $@.o -lm
	make clean
	mv $@ ${BINPATH}/$@

clean :	
	rm -f *.o
	
submit : clean push

.PHONY : select lab* clean submit

include git.mk

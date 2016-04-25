BINPATH = ..

select :
	echo Please select a valid make target

lab% : lab%.out lab%.c
	mv $< ${BINPATH}/$@/$@
	cp forall ${BINPATH}/$@
	cp sprint ${BINPATH}/$@
	ls ${BINPATH}/$@

lab%.out : lab%.c
	gcc -c -Wall -Werror --std=c99 $<
	gcc -o $@ ${@:.out=.o} -lm
	rm -f ${@:.out=.o}

slab% : lab%
	cp dsh.$<.*.f ${BINPATH}/$<
	${BINPATH}/$</sprint

clean :	
	rm -f *.o
	
submit : clean push

.PHONY : select lab* slab* clean submit

include git.mk

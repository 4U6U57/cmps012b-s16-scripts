BINPATH = ..

select :
	echo Please select a valid make target

lab% :  lab%.out lab%.c
	mv $< ${BINPATH}/$@/$@
	cp forall ${BINPATH}/$@
	cp sprint ${BINPATH}/$@
	ls ${BINPATH}/$@

lab%.out : lab%.c
	gcc -c -Wall -Werror --std=c99 $<
	gcc -o $@ ${@:.out=.o} -lm
	rm -f ${@:.out=.o}

slab% : lab% pull
	rm -f ${BINPATH}/$</dsh.*.sh
	cp dsh.$<.*.sh ${BINPATH}/$<
	${BINPATH}/$</sprint

flab% : lab%
	${BINPATH}/$</forall

clean :	
	rm -f *.o
	
submit : clean push

.PHONY : select lab* slab* flab* clean submit

include git.mk

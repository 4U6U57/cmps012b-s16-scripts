BINPATH = ..

select :
	echo Please select a valid make target

lab% : 
	#lab%.out lab%.c
	#mv $< ${BINPATH}/$@/$@
	cp $@.scripts/* ${BINPATH}/$@
	cp forall ${BINPATH}/$@
	ls ${BINPATH}/$@

lab%.out : lab%.c
	gcc -c -Wall -Werror --std=c99 $<
	gcc -o $@ ${@:.out=.o} -lm
	rm -f ${@:.out=.o}

slab% : lab% pull
	${BINPATH}/$</stable.sh

flab% : lab%
	${BINPATH}/$</forall

alab4 :
	cp lab4.scripts/lab4* ../lab4/

clean :	
	rm -f *.o
	
submit : clean push

.PHONY : select lab* slab* flab* nlab* clean submit

include git.mk

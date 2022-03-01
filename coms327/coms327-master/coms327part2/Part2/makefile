advance: readFile.o move.o
	gcc -o advance readFile.o move.o
readFile.o: readFile.o
	gcc -c -o readFile.o readFile.c
move.o: readFile.h move.c
	gcc -c -o move.o move.c
clean:
	rm *.o advance

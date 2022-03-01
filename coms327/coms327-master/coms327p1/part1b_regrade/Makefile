# Makefile

# target : dependencies
# 	action


all: parta partb

parta : gensine gendial

partb : dtmf

gensine: gensnd.o main.o
	gcc gensnd.o main.o -o gensine -l m

gensnd.o: gensnd.c gensnd.h
	gcc -c gensnd.c

main.o: main.c gensnd.h
	gcc -c main.c

gendial: gensnd.o main2.o
	gcc gensnd.o main2.o -o gendial -l m

main2.o: main2.c gensnd.c
	gcc -c main2.c

dtmf: gensnd.o main1b.o
	gcc gensnd.o main1b.o -o dtmf -l m

main1b.o: main1b.c gensnd.h
	gcc -c main1b.c

clean:
	rm *.o gensine gendial dtmf


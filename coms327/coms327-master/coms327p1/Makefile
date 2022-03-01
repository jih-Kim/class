# Makefile

# target : dependencies
# 	action

all : playsong

playsong: gensnd.o playsong.o process.o
	gcc gensnd.o playsong.o process.o -o playsong -l m

gensnd.o: gensnd.c gensnd.h
	gcc -c gensnd.c

playsong.o: playsong.c
	gcc -c playsong.c

process.o: process.c process.h
	gcc -c process.c

clean:
	rm *.o playsong

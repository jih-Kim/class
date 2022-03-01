#Makefile

#target : dependencies
#	action

candy : main.o candy.o piece.o pound.o
	g++ main.o candy.o piece.o pound.o -o candy

main.o : main.cpp
	g++ -c main.cpp

candy.o : candy.cpp candy.h
	g++ -c candy.cpp

piece.o : piece.cpp piece.h candy.h
	g++ -c piece.cpp

pound.o : pound.cpp pound.h candy.h
	g++ -c pound.cpp

clean:
	rm *.o candy
# Makefile

# target : dependencies
# 	action

all : parta  partb

parta: main.o SawtoothWave.o SineWave.o SquareWave.o TriangleWave.o wave.o soundio.o SoundSamples.o
	g++ main.o SawtoothWave.o SineWave.o SquareWave.o TriangleWave.o wave.o soundio.o SoundSamples.o -o parta -l m

partb: TestMain.o SawtoothWave.o SineWave.o SquareWave.o TriangleWave.o wave.o soundio.o SoundSamples.o
	g++ TestMain.o SawtoothWave.o SineWave.o SquareWave.o TriangleWave.o wave.o soundio.o SoundSamples.o -o partb -l m

TestMain.o : TestMain.cpp
	g++ -c TestMain.cpp

main.o : main.cpp
	g++ -c main.cpp

SawtoothWave.o : SawtoothWave.cpp SawtoothWave.h 
	g++ -c SawtoothWave.cpp

SineWave.o : SineWave.cpp SineWave.h
	g++ -c SineWave.cpp -l m

SquareWave.o : SquareWave.cpp SquareWave.h
	g++ -c SquareWave.cpp

TriangleWave.o : TriangleWave.cpp TriangleWave.h
	g++ -c TriangleWave.cpp

wave.o : wave.cpp wave.h
	g++ -c wave.cpp

SoundSamples.o : SoundSamples.cpp SoundSamples.h
	g++ -c SoundSamples.cpp

soundio.o : soundio.cpp soundio.h
	g++ -c soundio.cpp

clean:
	rm *.o parta partb


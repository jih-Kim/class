#include <iostream>
#include <string>
#include "SineWave.h"
#include "SquareWave.h"
#include "TriangleWave.h"
#include "SawtoothWave.h"
#include "wave.h"
#include "SoundSamples.h"
#include "soundio.h"
using namespace std;

int main() {
	std::cout.precision(5);
	int type;
	float SR;
	float fre;
	float dur;
	string filename;
	cout << "Enter the type 1 for sin, 2 for square, 3 for traingle, 4 for sawtooth" << endl;
	cin >> type;
	cout << "Enter the samplerate" << endl;
	cin >> SR;
	cout << "Enter the frequency" << endl;
	cin >> fre;
	cout << "Enter the duration" << endl;
	cin >> dur;
	cout << "Enter the filename" << endl;
	cin >> filename;
	Wave* w;
	SoundSamples* s;
	if (type == 1) {
		w = new SineWave("MySineWave");
		s = w->generateSamples(fre, SR, dur);
	}
	else if (type == 2) {
		w = new SquareWave("MySquareWave");
		s = w->generateSamples(fre, SR, dur);
	}
	else if (type == 3) {
		w = new TriangleWave("MyTriangleWave");
		s = w->generateSamples(fre, SR, dur);
	}
	else if (type == 4) {
		w = new SawtoothWave("MySawtoothWave");
		s = w->generateSamples(fre, SR, dur);
	}
	else {
		cout << "you have type wrong type" << endl;
	}
	soundio io;
	io.OutputSound(s, filename);
	return 0;
}

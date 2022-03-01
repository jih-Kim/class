#include <iostream>
#include <string>
#include <math.h>
#include "SineWave.h"
#include "SquareWave.h"
#include "TriangleWave.h"
#include "SawtoothWave.h"
#include "wave.h"
#include "SoundSamples.h"
#include "soundio.h"
using namespace std;

int main() {
	int type;
	float SR;
	float dur;
	float delay;
	float attenuation;
	float atime;
	float alevel;
	float dtime;
	float slevel;
	float rtime;
	string filename;
	cout << "Enter the type 1 for sin, 2 for square, 3 for traingle, 4 for sawtooth" << endl;
	cin >> type;
	SR = 8000;
	cout << "Enter the duration" << endl;
	cin >> dur;
	cout << "Enter the filename" << endl;
	cin >> filename;
	cout << "Enter the delay for delay method" << endl;
	cin >> delay;
	cout << "Enter the attenuation for delay method" << endl;
	cin >> attenuation;
	cout << "Enter the atime" << endl;
	cin >> atime;
	cout << "Enter the alevel" << endl;
	cin >> alevel;
	cout << "Enter the dtime" << endl;
	cin >> dtime;
	cout << "Enter the slevel" << endl;
	cin >> slevel;
	cout << "Enter the rtime" << endl;
	cin >> rtime;
	float fre = 1;
	//ArrayList<SoundSamples> temp2 = new ArrayList<SoundSamples>();
	while (!(fre < 0)) {
		cout << "Enter the node finish when you type negative number" << endl;
		cin >> fre;
		if (fre > 0) {
			fre = pow(2, ((fre - 49) / 12)) * 440;
		}
		else
			break;
		Wave* w;
		SoundSamples* s = new SoundSamples();
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
		s->reverb2(delay, attenuation);
		s->adsr(atime, alevel, dtime, slevel, rtime);
		soundio io;
		io.OutputSound(s, filename);
	}
}

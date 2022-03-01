#include <iostream>
#include <fstream>
#include <iomanip>
#include "soundio.h"
using namespace std;


void soundio::OutputSound(SoundSamples* samples, string filename) {
	ofstream myfile(filename, ios::app);
	if (myfile.is_open()) {
		for (int i = 0; i < samples->length(); i++) {
			myfile << fixed << setprecision(5);
			myfile << samples->getSamples()[i] << endl;
		}
	}
	else {
		cout << "Unable to open file" << endl;
	}
}

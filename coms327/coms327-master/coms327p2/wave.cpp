#include "wave.h"
#include <math.h>
#include <iostream>
#define _USE_MATH_DEFINES

using namespace std;

Wave::Wave() {
	name = "noName";
}

Wave::Wave(string names) {
	name = names;
}
void Wave::setName(string names) {
	name = names;
}
string Wave::getName() {
	return name;
}

SoundSamples* Wave::generateSamples(float frequency, float samplerate, float duration) {
	SoundSamples* result = new SoundSamples();
	result->setSampleRate(samplerate);
	result->setlength(samplerate * duration);
	const double pi = 3.14159265358979f;
	float* data = new float[result->length()];
	float radian = 0;
	for (int i = 0; i < result->length(); i++) {
		data[i] = generateFunction(radian);
		radian = radian + 2 * pi / samplerate * frequency;
	}
	result->setSamples(data);
	return result;
}
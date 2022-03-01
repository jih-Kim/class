#include "SoundSamples.h"
#include <iostream>

using namespace std;

SoundSamples::SoundSamples() {
	numberOfSample = 0;
	sampleRate = 8000;
}

SoundSamples::SoundSamples(float* sample, int length, float samplerate) {
	samples = sample;
	numberOfSample = length;
	sampleRate = samplerate;
}

SoundSamples::SoundSamples(int length, float samplerate) {
	numberOfSample = length;
	sampleRate = samplerate;
}

SoundSamples::SoundSamples(const SoundSamples& target) {
	samples = new float[target.numberOfSample];
	for (int i = 0; i < target.numberOfSample; i++) {
		samples[i] = target.samples[i];
	}
	sampleRate = target.sampleRate;
	numberOfSample = target.numberOfSample;
}

void SoundSamples::setSampleRate(float sample) {
	sampleRate = sample;
}

float SoundSamples::getSampleRate() {
	return sampleRate;
}

void SoundSamples::setlength(int length) {
	numberOfSample = length;
}

int SoundSamples::length() {
	return numberOfSample;
}

float* SoundSamples::getSamples() {
	return samples;
}
void SoundSamples::setSamples(float* sample) {
	samples = sample;
}

void SoundSamples::operator=(const SoundSamples& sound) {
	samples = new float[sound.numberOfSample];
	for (int i = 0; i < sound.numberOfSample; i++) {
		samples[i] = sound.samples[i];
	}
	numberOfSample = sound.numberOfSample;
	sampleRate = sound.sampleRate;
}

float& SoundSamples::operator[](int index) {
	if (index >= numberOfSample) {
		cout << "Wrong input"<<endl;
		float a = -1;
		return a;
	}
	return samples[index];
}

SoundSamples SoundSamples::operator+(const SoundSamples& sound) {
	SoundSamples result;
	if (numberOfSample != sound.numberOfSample)
		cout << "size is not same" << endl;
	result.numberOfSample = numberOfSample;
	result.sampleRate = sampleRate;
	float* sample = new float[sound.numberOfSample];
	for (int i = 0; i < numberOfSample; i++) {
		sample[i] = samples[i] + sound.samples[i];
	}
	result.samples = sample;
	return result;
}

void SoundSamples::reverb2(float delay, float attenuation) {
	if (attenuation < 0 || delay<0) {
		cout << "attenuation or delay have to be greater or equal to 0" << endl;
		return;
	}
	float* result = new float[numberOfSample];
	int temp = delay * sampleRate;
	for (int i = 0; i < numberOfSample; i++) {
		if (i - temp<0 || result[(int)(i-temp)] == 0) {
			result[i] = samples[i];
		}
		else {
			result[i] = samples[i] + result[(int)(i - temp)] * attenuation;
		}
	}
	delete[] samples;
	samples = result;
}

void SoundSamples::adsr(float atime, float alevel, float dtime, float slevel, float rtime) {
	float* result = new float[numberOfSample];
	for (int i = 0; i < numberOfSample; i++) {
		if (i < atime) {
			result[i] = samples[i]*(alevel / atime * i);
		}
		if (i>=atime && i < atime + dtime) {
			result[i] = samples[i] * ((slevel - alevel) / dtime * i + (alevel * dtime - atime * slevel + atime * alevel) / dtime);
		}
		if (i>=atime+dtime && i < numberOfSample - rtime) {
			result[i] = samples[i] * slevel;
		}
		if(i>=numberOfSample-rtime && i<=numberOfSample-1)
			result[i] = samples[i]*(slevel / rtime * (numberOfSample - 1 - i));
	}
	delete[] samples;
	samples = result;
}
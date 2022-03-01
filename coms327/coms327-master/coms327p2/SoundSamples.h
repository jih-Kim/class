#include <iostream>
#pragma once
class SoundSamples {
public :
	SoundSamples();
	SoundSamples(float* sample, int length, float samplerate);
	SoundSamples(int length, float samplerate);
	SoundSamples(const SoundSamples& target);
	void setSampleRate(float sample);
	float getSampleRate();
	void setlength(int length);
	int length();
	float* getSamples();
	void setSamples(float* sample);
	void operator=(const SoundSamples& sound);
	float& operator[](int index);
	SoundSamples operator+(const SoundSamples& sound);
	void reverb2(float delay, float attenuation);
	void adsr(float atime, float alevel,float dtime,float slevel,float rtime);
protected :
	float* samples;
	float sampleRate;
	int numberOfSample;
};
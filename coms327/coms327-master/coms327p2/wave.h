#include <iostream>
#include "SoundSamples.h"
#pragma once
using namespace std;

class Wave {
public:
	Wave();
	Wave(string names);
	void setName(string names);
	string getName();
	virtual float generateFunction(float time) = 0;
	SoundSamples* generateSamples(float frequency, float samplerate, float duration);
	//genSamples class once genfunction call each time depency
protected:
	string name;
	float frequency;
};
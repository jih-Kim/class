#pragma once
#include "SoundSamples.h"
#include <iostream>
using namespace std;

class soundio {
public :
	void OutputSound(SoundSamples* samples, string filename);
};
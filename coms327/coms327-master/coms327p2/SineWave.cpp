#include "SineWave.h"
#include <math.h>
#include <iostream>
using namespace std;


SineWave::SineWave(string names) {
	name = names;
}

float SineWave::generateFunction(float time) {
	return sin(time);
}


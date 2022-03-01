#include "SquareWave.h"
#include <iostream>
#include <math.h>
using namespace std;

SquareWave::SquareWave(string names) {
	name = names;
}

float SquareWave::generateFunction(float time) {
	if (sin(time) < 0)
		return 1;
	else
		return -1;
}
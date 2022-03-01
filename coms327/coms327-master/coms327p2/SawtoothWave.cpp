#include "SawtoothWave.h"
#include <iostream>
using namespace std;

SawtoothWave::SawtoothWave(string names) {
	name = names;
}


float SawtoothWave::generateFunction(float time) {
	const double pi = 3.14159265358979f;
	int temp = time / pi / 2;
	return 1 / pi * time - 1 - 2 * temp;
}

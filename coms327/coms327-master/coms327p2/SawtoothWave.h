#pragma once
#include "wave.h"

class SawtoothWave : public Wave
{
public:
	SawtoothWave(string names);
	float generateFunction(float time);

private:

};

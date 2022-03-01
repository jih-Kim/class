#include "TriangleWave.h"
#include <math.h>
#include <iostream>
using namespace std;

TriangleWave::TriangleWave(string names) {
        name = names;
}

float TriangleWave::generateFunction(float time) {
        const double pi = 3.14159265358979f;
        time = fmod(time ,2 * pi);
        if (time < pi || time == 0) {
                return 2 / pi * time - 1;
        }
        else {
                return -(2 / pi * time) + 3;
        }
}



#include <math.h>
#include <stdio.h>
#include "sound.h"

sound* gensine(float hertz, float sample_rate, float duration);
sound* genDTMF(char key, float sample_rate, float duration);
sound* saveSumOfSin(int firstHZ, int secondHZ);
sound* genPhonePad(char entered);
sound* genSilence(float sample_rate, float duration);
sound* genSquare(float hertz, float sample_rate, float duration);
sound* genTriangle(float hertz, float sample_rate, float duration);
sound* genSawtooth(float hertz, float sample_rate, float duration);


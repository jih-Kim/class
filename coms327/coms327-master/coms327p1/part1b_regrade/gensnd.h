#include <math.h>
#include <stdio.h>

void gensine(float freq, float SR, float duration);
void gensine(float freq, float SR, float duration);
void printSumOfSin(int firstHZ, int secondHZ);
void inputPhonePad(char entered);
void silence(float sampleRate, float duration);

typedef struct sound_t {
	float* sample;
	int length;
	float rate;
}sound;
sound* gensine2(float hertz, float sample_rate, float duration);
sound* saveSumOfSin(int firstHZ, int secondHZ);
sound* genPhonePad(char entered);
sound* genDTMF2(char key, float sample_rate, float duration);
sound* genSilence(float sample_rate, float duration);
int outputSound(sound* s, FILE* f);


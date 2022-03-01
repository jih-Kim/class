/*
 * This line basically imports the stdio header file, part of the standard library, and gensnd header file. It provide input, output and gensine method functionality to the program.
 * */
#include "gensnd.h"
#include <stdio.h>

/* This main test the gensine, which shows the result of sine value when user type frequency, sampleRate, and duration.
 * */


int main(void) {
	float frequency;
	float sampleRate;
	float duration;
	scanf("%f", &frequency);
	scanf("%f", &sampleRate);
	scanf("%f", &duration);
	if(frequency < 0 || sampleRate < 0 || duration < 0)
	{
		printf("Frequency or sample rate or duration can't be negative\n");
		printf("Please check your input and restart the program\n");
		return 0;
	}
	gensine(frequency, sampleRate, duration);
	return 0;
}

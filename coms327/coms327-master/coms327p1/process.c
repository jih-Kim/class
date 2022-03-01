#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "songSound.h"
#include "iosnd.h"
#include "sound.h"
#include "gensnd.h"
#include "process.h"

sound* mix(sound* s[],  float w[], int c) {
	sound* result = malloc(sizeof(sound));
	int max = 0;
	for (int i = 0; i < c; i++) {
		if (max < s[i]->length)
			max = s[i]->length;
	}
	result->samples = malloc(sizeof(float) * max);
	for (int i = 0; i < max; i++) {
		result->samples[i] = 0;
	}
	for (int j = 0; j < max; j++) {
		for (int i = 0; i < c; i++) {
		int size = s[i]->length;
			if (j > size) {
				result->samples[j] = result->samples[j] + 0;
			}
			else {
				result->samples[j] = result->samples[j] + s[i]->samples[j] * w[i];
			}
		}
	}
	result->length = max;
	result->rate = s[c-1]->rate;
	return result;
}

sound* modulate(sound* s1, sound* s2) {
	sound* result = malloc(sizeof(sound));
	if (s1->rate != s2->rate) {
		printf("rate is not same in modulate function\n");
		return NULL;
	}
	if (s1->length != s2->length) {
		printf("length is not same in modulate function\n");
		return NULL;
	}
	for (int i = 0; i < s1->length; i++) {
		result->samples[i] = s1->samples[i] * s2->samples[i];
	}
	result->length = s1->length;
	result->rate = s1->rate;
	return result;
}

sound* filter(sound* s, float fir[], int c) {   //have to think about s and fir size is different
	if (s == NULL) {
		printf("s is NULL in filter function\n");
		return NULL;
	}
	sound* result = malloc(sizeof(sound));
	result->length = s->length;
	result->samples = s->samples;
	result->samples = malloc(sizeof(float) * s->length);
	for (int i = 0; i < s->length; i++) {
		result->samples[i] = 0.0;
	}
	for (int i = 0; i < s->length; i++) {				
		for (int j = 0; j < c; j++) {
			if (i - j < 0) {
				result->samples[i] = result->samples[i] + 0;
			}
			else {
				result->samples[i] = result->samples[i] + s->samples[i-j] * fir[j]; 
			}
		}
	}
	return result;
}

sound* reverb(sound* s, float delay, float attenuation) {
	if (attenuation > 1 || attenuation < 0) {
		printf("attuenuation is wrong in reverb function\n");
		return NULL;
	}
	if (delay < 0 || delay > 0.1) {
		printf("delay is wrong in reverb function\n");
		return NULL;
	}
	if (s == NULL) {
		printf("pointer s is NULL in reverb function\n");
		return NULL;
	}
	sound* result;
	int size = s->rate*delay;
	float* fir = malloc(sizeof(float) * size+1);
	fir[0] = 1.0;		
	for (int i = 1; i < size; i++) {
		fir[i] = 0.0;
	}
	fir[size] = attenuation;
	result = filter(s, fir, size+1);
	return result;
}

sound* echo(sound* s, float delay, float attenuation) {
	if (attenuation > 1 || attenuation < 0) {
		printf("attuenuation is wrong in echo function\n");
		return NULL;
	}
	if (delay < 0.1 || delay > 1) {
		printf("delay is wrong in echo function\n");
		return NULL;
	}
	if (s == NULL) {
		printf("pointer s is NULL in echo function\n");
		return NULL;
	}
	sound* result;
	int size = s->rate * delay;
	float* fir = malloc(sizeof(float) * size + 1);
	fir[0] = 1.0;
	for (int i = 1; i < size; i++) {
		fir[i] = 0.0;
	}
	fir[size] = attenuation;
	result = filter(s, fir, size + 1);
	return result;
}

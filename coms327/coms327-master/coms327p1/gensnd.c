/*
 * This c file include math header file and stdio header file. Math header file provide to use sin method and M_PI value, which indicates pi. Stdio header file provide input and output functionality to the program
 * */
#define _USE_MATH_DEFINES
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "songSound.h"
#include "iosnd.h"
#include "sound.h"
#include "gensnd.h"
#include "process.h"

/*
* This method return the sound* which similar to gensine in part a
*/
sound* gensine(float hertz, float sample_rate, float duration) {
	sound* result = (sound*)malloc(sizeof(sound));
	result->length = sample_rate * duration;
	float cycle;
	cycle = sample_rate / hertz;
	result->samples = (float*)malloc(result->length * sizeof(float));
	float radian = 0;
	for (int j = 0; j < result->length; j++) {
		result->samples[j] = sin(radian);
		radian = radian + 2 * M_PI / cycle;
	}
	result->rate = sample_rate;
	return result;
}


sound* saveSumOfSin(int firstHZ, int secondHZ) {
	sound* first;
	sound* second;
	first = gensine(firstHZ, 8000, 0.5);
	second = gensine(secondHZ, 8000, 0.5);
	sound* data = malloc(sizeof(sound));
	data->samples = (float*)malloc(sizeof(float) *4000);
	for (int i = 0; i < 4000; i++){
		data->samples[i] = (first->samples[i] + second->samples[i])/2;
	}
	data->length = 4000;
	data->rate = 8000;
	free(first->samples);
	free(second->samples);
	free(first);
	free(second);
	return data;
}


sound* genPhonePad(char entered) {
	sound* data;
	switch (entered) {
	case '1':
		data = saveSumOfSin(1209, 697);
		return data;
	case '2':
		data = saveSumOfSin(1336, 697);
		return data;
	case '3':
		data = saveSumOfSin(1477, 697);
		return data;
	case 'a':
		data = saveSumOfSin(1633, 697);
		return data;
	case 'A':
		data = saveSumOfSin(1633, 697);
		return data;
	case '4':
		data = saveSumOfSin(1209, 770);
		return data;
	case '5':
		data = saveSumOfSin(1336, 770);
		return data;
	case '6':
		data = saveSumOfSin(1477, 770);
		return data;
	case 'B':
		data = saveSumOfSin(1633, 770);
		return data;
	case 'b':
		data = saveSumOfSin(1633, 770);
		return data;
	case '7':
		data = saveSumOfSin(1209, 852);
		return data;
	case '8':
		data = saveSumOfSin(1336, 852);
		return data;
	case '9':
		data = saveSumOfSin(1477, 852);
		return data;
	case 'C':
		data = saveSumOfSin(1633, 852);
		return data;
	case 'c':
		data = saveSumOfSin(1633, 852);
		return data;
	case '*':
		data = saveSumOfSin(1209, 941);
		return data;
	case '0':
		data = saveSumOfSin(1336, 941);
		return data;
	case '#':
		data = saveSumOfSin(1477, 941);
		return data;
	default:
		data =saveSumOfSin(1633, 941);
		return data;
	}
}

sound* genDTMF(char key, float sample_rate, float duration) {
	sound* result;
	result = genPhonePad(key);
	return result;
}

sound* genSilence(float sample_rate, float duration) {
	sound* result = malloc(sizeof(sound));
	result->length = (int)sample_rate * duration + 1;
	result->rate = sample_rate;
	result->samples = malloc(sizeof(float) * result->length);
	for (int i = 0; i < sample_rate * duration; i++) {
		result->samples[i] = 0.0;
	}
	return result;
}

sound* genSquare(float hertz, float sample_rate, float duration) {	
	sound* result = (sound*)malloc(sizeof(sound));
	result->length = sample_rate * duration;
	float cycle;
	cycle = sample_rate / hertz;
	result->samples = (float*)malloc(result->length * sizeof(float));
	float radian = 0;
	for (int j = 0; j < result->length; j++) {
		if (sin(radian) < 0) {
			result->samples[j] = 1;
		}
		else {
			result->samples[j] = -1;
		}
		radian = radian + 2 * M_PI / cycle;
	}
	result->rate = sample_rate;
	return result;
}


sound* genTriangle(float hertz, float sample_rate, float duration) {
	sound* result = (sound*)malloc(sizeof(sound));
	result->length = sample_rate * duration;
	float cycle;
	cycle = sample_rate / hertz;
	result->samples = (float*)malloc(result->length * sizeof(float));
	float radian = 0;
	for (int j = 0; j < result->length; j++) {
		if (radian < M_PI || radian == 0) {
			result->samples[j] = 2 / M_PI * radian - 1;
		}
		else{
			result->samples[j] = - (2 / M_PI * radian) + 3;
		}
		radian = radian + 2 * M_PI / cycle;
		radian = fmod(radian, 2 * M_PI);
	}
	result->rate = sample_rate;
	return result;
}


sound* genSawtooth(float hertz, float sample_rate, float duration) {
	sound* result = (sound*)malloc(sizeof(sound));
	result->length = sample_rate * duration;
	float cycle;
	cycle = sample_rate / hertz;
	result->samples = (float*)malloc(result->length * sizeof(float));
	float radian = 0;
	int time;
	for (int j = 0; j < result->length; j++) {
		time = radian * 1 / M_PI / 2;
		result->samples[j] = 1 / M_PI * radian -1 - 2 * time;
		radian = radian + 2 * M_PI / cycle;
	}
	result->rate = sample_rate;
	return result;
}
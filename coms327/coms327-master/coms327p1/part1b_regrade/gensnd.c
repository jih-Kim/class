/*
 * This c file include math header file and stdio header file. Math header file provide to use sin method and M_PI value, which indicates pi. Stdio header file provide input and output functionality to the program
 * */
#define _USE_MATH_DEFINES
#include <math.h>
#include <stdio.h>
#include "gensnd.h"

/*
 * Function declaration. This output the sin value which use specific freqency, sample rate, and duration. It will require frequency, sample rate, duration as input. Output the sin values.
 * @para float freq, float SR, float duration
 * */
void gensine(float freq, float SR, float duration) {
	float numberOfSample;
	numberOfSample = SR * duration;
	float cycle;
	cycle = SR / freq;
	for (double radian = 0; radian < 2 * M_PI * freq * duration ; radian = radian + 2 * M_PI / cycle)
	{
		printf("%f\n", sin(radian));
	}
}

/*
 * Function (method) declaration. This method is helper method that help to calculate the sum of two sin value. This method require the firstHZ and secondHz to calculate the sin value.
 * @para int firstHZ, int secondHZ
 * */
void printSumOfSin(int firstHZ, int secondHZ) {
	float firstRadian = 0;
	float secondRadian = 0;
	for (int i = 0; i < 4000; i++)
	{
		printf("%f\n", (sin(firstRadian) + sin(secondRadian)) / 2);
		firstRadian = firstRadian + 2 * M_PI / 8000 * firstHZ;
		secondRadian = secondRadian + 2 * M_PI / 8000 * secondHZ;
	}
}

/* Function (method) declaration. This method find the character entered and output two sin value using printSumOfSin helper method. It requires character.
 * @para char entered
 * */
void inputPhonePad(char entered) {
	switch (entered) {
	case '1':
		printSumOfSin(1209, 697);
		break;
	case '2':
		printSumOfSin(1336, 697);
		break;
	case '3':
		printSumOfSin(1477, 697);
		break;
	case 'a':
		printSumOfSin(1633, 697);
		break;
	case 'A':
		printSumOfSin(1633, 697);
		break;
	case '4':
		printSumOfSin(1209, 770);
		break;
	case '5':
		printSumOfSin(1336, 770);
		break;
	case '6':
		printSumOfSin(1477, 770);
		break;
	case 'B':
		printSumOfSin(1633, 770);
		break;
	case 'b':
		printSumOfSin(1633, 770);
		break;
	case '7':
		printSumOfSin(1209, 852);
		break;
	case '8':
		printSumOfSin(1336, 852);
		break;
	case '9':
		printSumOfSin(1477, 852);
		break;
	case 'C':
		printSumOfSin(1633, 852);
		break;
	case 'c':
		printSumOfSin(1633, 852);
		break;
	case '*':
		printSumOfSin(1209, 941);
		break;
	case '0':
		printSumOfSin(1336, 941);
		break;
	case '#':
		printSumOfSin(1477, 941);
		break;
	default:
		printSumOfSin(1633, 941);
	}
}

/*
 * Function (method) declaration. This method print the number of 0 in specific sampleRate and duration. It requires sampleRate and duration as input.
 * @para - float sampleRate, float duration
 * */
void silence(float sampleRate, float duration)
{
	for (int i = 0; i < sampleRate * duration; i++) {
		printf("%f\n", 0.0);
	}
}

/*
 * It works similar to gensine in part a but it save the output as data
 * @para - float hertz, float sample_rate, float duration
 * @return - sound* 
 * */
sound* gensine2(float hertz, float sample_rate, float duration) {
	sound* result = (sound*)malloc(sizeof(sound));
	result->length = sample_rate * duration;
	float cycle;
	cycle = sample_rate / hertz;
	int i = 0;
	for (float radian = 0; radian <= 2 * M_PI * hertz * duration; radian = radian + 2 * M_PI / cycle)
		i++;
	result->samples = (float*)malloc(i * sizeof(float));
	result->length = i;
	float radian = 0;
	for (int i = 0; i < sample_rate * duration; i++) {
		result->samples[i] = sin(radian);
		radian = radian + 2 * M_PI / cycle;
	}
	result->rate = sample_rate;
	return result;
}

/*
 * It calculate the sum of two sin and save as data
 * @para - int firstHZ, int secondHZ
 * @return - sound*
 * */
sound* saveSumOfSin(int firstHZ, int secondHZ) {
	sound* first;
	sound* second;
	first = gensine2(firstHZ, 8000, 0.5);
	second = gensine2(secondHZ, 8000, 0.5);
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

/*
 * It check the character enterd and call right hz and saveSumOFSin helper method
 * @para - char entered
 * @return - sound*
 * */
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

/*
 *It calls helper method genPhonePad to find the result
 *@para - char key, float sample_rate, float duration
 *@return - sound*
 * */
sound* genDTMF2(char key, float sample_rate, float duration) {
	sound* result;
	result = genPhonePad(key);
	return result;
}

/*
 * This method create the silence data
 * @para float sample_rate, float duration
 * @return sound*
 * */
sound* genSilence(float sample_rate, float duration) {
	sound* result = (sound*)malloc(sizeof(sound));
	result->samples = (float*)malloc(sizeof(float) * sample_rate * duration);
	for (int i = 0; i < sample_rate * duration; i++) {
		result->samples[i] = 0.0;
	}
	result->length = sample_rate * duration;
	result->rate = sample_rate;
	return result;
}

/*
 *This method save the sound data into file f.
 *@para sound* s, FILE *f
 *@return int
 * */
int outputSound(sound* s, FILE *f) {
	if (f == NULL)
		return 1;
	//f = fopen(f, "w");
	for (int i = 0; i < s->length; i++) {
		fprintf(f, "%f\n", s->samples[i]);
	}
	//fclose(f);
	return 0;
}


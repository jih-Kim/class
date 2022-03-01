//#include <stdio.h>
//#include <stdlib.h>
//#include "process.h"
//#include "sound.h"
//#include "iosnd.h"
/*
int main() {
	int size = 2;
	sound** temp = malloc(sizeof(sound*) * size);
	for (int i = 0; i < size; i++) {
		temp[i] = malloc(sizeof(sound));
	}

	temp[0]->length = 4;
	temp[1]->length = 6;
	for (int i = 0; i < size; i++) {
		temp[i]->samples = malloc(sizeof(float) * temp[i]->length);
	}

	temp[0]->samples[0] = 0.9;
	temp[0]->samples[1] = 0.6;
	temp[0]->samples[2] = 0.3;
	temp[0]->samples[3] = 0.6;

	temp[1]->samples[0] = 0.4;
	temp[1]->samples[1] = 0.8;
	temp[1]->samples[2] = 0.8;
	temp[1]->samples[3] = 0.2;
	temp[1]->samples[4] = 0.3;
	temp[1]->samples[5] = 0.2;


	float w[] = { 0.3, 0.5};
	//float temp2[2] = {0.5, 0.3};
	sound* result;
	result = mix(temp, 2, w, 2);
	for (int j = 0; j < result->length; j++) {
		printf("%f\n", result->samples[j]);
	}
	
	return 0;
}
*/
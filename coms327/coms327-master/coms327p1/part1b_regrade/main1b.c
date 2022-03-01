#define _CRT_SECURE_NO_WARNINGS
#include "gensnd.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*
 *This main test the part b. It test if the data is calculate correctly and save into file if there is file name. It input the 10 digit number and create sound wave which relate to that number
 It return error message if there is no or less string command when using this file.Also it checks if the number that user input is right input or not and return error message if there is missing part.
 When the program find the error it simply finish the program. So user have to restart this program with right input.
 * */
int main(int argc, char* argv[]) {
	if (argv[0] == NULL) {
		printf("Input invalid error\n");
		printf("type two or three string\n");
		printf("First string is filename\n");
		printf("second string is number\n");
		printf("third string is output filename\n");
		printf("restart the program\n");
		return 0;
	}
	if (argv[1] == NULL) {
		printf("number invalid error\n");
		printf("input the number to execute the file\n");
		printf("restart the program\n");
		return 0;
	}
	char phoneNumber[100];
	strcpy(phoneNumber, argv[1]);
	int size = strlen(phoneNumber);
	for (int i = 0; i < size; i++)
	{
		if (phoneNumber[i] == '1' || phoneNumber[i] == '2' || phoneNumber[i] == '3' || phoneNumber[i] == '4' || phoneNumber[i] == '5'
			|| phoneNumber[i] == '6' || phoneNumber[i] == '7' || phoneNumber[i] == '8' || phoneNumber[i] == '9' || phoneNumber[i] == '0'
			|| phoneNumber[i] == 'A' || phoneNumber[i] == 'a' || phoneNumber[i] == 'B' || phoneNumber[i] == 'b' || phoneNumber[i] == 'C'
			|| phoneNumber[i] == 'c' || phoneNumber[i] == 'D' || phoneNumber[i] == 'd' || phoneNumber[i] == '#' || phoneNumber[i] == '*')
		{

		}
		else
		{
			printf("Invalid input: Please check your input and start again\n");
			return 0;
		}
	}
	sound** result2 = malloc(sizeof(sound*)*size*2-1);
	int i = 0;
	while(i < 2*size-1)
	{
		char temp = phoneNumber[i];  
		result2[i]= genDTMF2(temp, 8000, 0.5);
		i++;
		if (i != size) {
			result2[i] = genSilence(8000, 0.25);
			i++;
		}
	}
	char filename[100];
	int success;
	if (argv[2] == NULL) {
		for (int i = 0; i < 2 * size - 1; i++) {
			for (int j = 0; j < result2[i]->length; j++) {
				printf("%f\n", result2[i]->sample[j]);
			}
		}
	}
	else {
		strcpy(filename, argv[2]);
		FILE* f = fopen(filename, "w");
		for (int i = 0; i < 2 * size - 1; i++) {
			success = outputSound(result2[i], f);
			if (success) {
				printf("there is error in outputSound function\n");
				printf("Start the program again\n");
			}
		}
		fclose(f);
	}
	//free part
	for (int j = 0; j <=2*size-1; j++) {
		free(result2[j]->sample);
		free(result2[j]);
	}
	return 0;
}


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "songSound.h"
#include "iosnd.h"
#include "sound.h"
#include "gensnd.h"
#include "process.h"

void sortArray(note* notes, int size);
int findIndex(int target, ssong* range, int size);

int main(int argc, char* argv[]) {
	int f = 0;
	int d = 0;
	if (argv[1] == NULL) {
		printf("Invalid filename\n");
		return 0;
	}
	FILE* fp;
	char buff[256];
	fp = fopen(argv[1], "r");
	if (fp == NULL) {
		printf("Can't find the file\n");
		return 0;
	}
	int sampleRate;
	int waveSize = 0;
	int soundSize = 0;
	int checkSong = 0;
	int songSize = 0;
	while (1) {
		if (fscanf(fp, "%s", &buff) == EOF) {
			break;
		}
		if (strcmp(buff, "SAMPLERATE") == 0) {
			fscanf(fp, "%s", &buff);
			sampleRate = atoi(buff);
		}
		if (strcmp(buff, "WAVE") == 0) {
			waveSize++;
		}
		if (strcmp(buff, "SOUND") == 0) {
			soundSize++;
		}
		if (strcmp(buff, "SONG") == 0) {
			checkSong = 1;
		}
		if (checkSong) {
			songSize++;
		}
	}
	fclose(fp);
	song* songData = malloc(sizeof(song) * waveSize);
	ssong* ssongData = malloc(sizeof(ssong) * soundSize);
	note* noteData = malloc(sizeof(note) * songSize);
	//0 for sine, 1 for square, 2 for triangle, 3 for saw
	int i = 0;
	int j = 0;
	int k = 0;
	checkSong = 0;
	fp = fopen(argv[1], "r");
	while (1) {
		if (fscanf(fp, "%s", &buff) == EOF) {
			break;
		}
		if (strcmp(buff, "WAVE") == 0) {
			fscanf(fp, "%s", &buff);
			strcpy(songData[i].name, buff);

			fscanf(fp, "%s", &buff);
			if (strcmp(buff, "sine") == 0) {
				songData[i].type = 0;
			}
			if (strcmp(buff, "square") == 0) {
				songData[i].type = 1;
			}
			if (strcmp(buff, "triangle") == 0) {
				songData[i].type = 2;
			}
			if (strcmp(buff, "saw") == 0) {
				songData[i].type = 3;
			}

			fscanf(fp, "%s", &buff);
			songData[i].delay = atof(buff);

			fscanf(fp, "%s", &buff);
			songData[i].attenuation = atof(buff);
			i++;
		}
		if (strcmp(buff, "SOUND") == 0) {
			fscanf(fp, "%s", &buff);
			strcpy(ssongData[j].name, buff);
			ssongData[j].size = 0;
			ssongData[j].waveData = malloc(sizeof(wave));
			ssongData[j].waveData->next = NULL;
			while (1) {
				fscanf(fp, "%s", &buff);
				if (strcmp(buff, "SONG") == 0)
					break;
				if (strcmp(buff, "SOUND") == 0) {
					j++;
					ssongData[j].size = 0;
					ssongData[j].waveData = malloc(sizeof(wave));
					ssongData[j].waveData->next = NULL;
					fscanf(fp, "%s", &buff);
					strcpy(ssongData[j].name, buff);
				}
				else {
					int index = strlen(buff);
					wave* cur = ssongData[j].waveData;
					if (ssongData[j].size == 0) {
						cur->waveIndex = buff[index - 1] - '0';
						fscanf(fp, "%s", &buff);
						cur->mixValue = atof(buff);
					}
					else {
						while (cur->next != NULL) {
							cur = cur->next;
						}
						cur->next = malloc(sizeof(wave));
						cur->next->waveIndex = buff[index - 1] - '0';
						fscanf(fp, "%s", &buff);
						cur->next->mixValue = atof(buff);
						cur->next->next = NULL;
					}
					ssongData[j].size++;
				}
			}
		}
		if (strcmp(buff, "SONG") == 0) {
			checkSong = 1;
		}
		if (checkSong) {
			while (1) {
				if (fscanf(fp, "%s", &buff) == EOF)
					break;
				int index = strlen(buff);
				noteData[k].soundIndex = buff[index - 1] - '0';
				fscanf(fp, "%s", &buff);
				float temp = atof(buff);
				float number1 = (temp - 49) / 12;
				noteData[k].frequency = (pow(2, number1)) * 440;
				fscanf(fp, "%s", &buff);
				noteData[k].start_time = atof(buff);
				fscanf(fp, "%s", &buff);
				noteData[k].duration = atof(buff);
				k++;
			}
		}
		sortArray(noteData, k);
	}
	fclose(fp);

	//saved all the data so start the playing
	sound** date;
	sound* temp;
	sound** data = malloc(sizeof(sound*) * k);
	int dIndex = 0;
	int resultSize = 1;
	int rSize = 0;
	for (int index = 0; index < k; index++) {
		int t = findIndex(noteData[index].soundIndex, ssongData, j + 1);
		if (t == -1) {
			printf("error in findindex\n");
		}
		else {
			date = malloc(sizeof(sound*) * ssongData[t].size);
			wave* cur = ssongData[t].waveData;
			for (int e = 0; e < ssongData[t].size; e++) { //0 for sine, 1 for square, 2 for triangle, 3 for saw
				if (songData[(cur->waveIndex) - 1].type == 0) {
					temp = gensine(noteData[index].frequency, sampleRate, noteData[index].duration);
					d = d + 2;
				}
				if (songData[(cur->waveIndex) - 1].type == 1) {
					temp = genSquare(noteData[index].frequency, sampleRate, noteData[index].duration);
					d = d + 2;
				}
				if (songData[(cur->waveIndex) - 1].type == 2) {
					temp = genTriangle(noteData[index].frequency, sampleRate, noteData[index].duration);
					d = d + 2;
				}
				if (songData[(cur->waveIndex) - 1].type == 3) {
					temp = genSawtooth(noteData[index].frequency, sampleRate, noteData[index].duration);
					d = d + 2;
				}
				if (temp == NULL) {
					printf("There is error\n");
					return 0;
				}
				date[e] = temp;
				cur = cur->next;
			}//making sound * for mix
			float* w = malloc(sizeof(float) * ssongData[t].size);
			wave* waveData = ssongData[t].waveData;
			for (int e = 0; e < ssongData[t].size; e++) {
				w[e] = waveData->mixValue;
				waveData = waveData->next;
			}
			temp = mix(date, w, ssongData[t].size);
			d = d + 2;
			data[dIndex] = temp;
			dIndex++;
			free(w);
			for (int e = 0; e < ssongData[t].size; e++) {
				free(date[e]->samples);
				free(date[e]);
			}
			free(date);
		}
	}
	for (int e = 1; e < k; e++) {
		if (noteData[e].start_time != noteData[e - 1].start_time)
			resultSize++;
		if (noteData[e].start_time > noteData[e - 1].start_time + noteData[e - 1].duration) {
			resultSize++;
		}
	}
	sound** result = malloc(sizeof(sound*) * resultSize);
	int resultInt = 0;
	int compareInt = 0;
	for (int e = 0; e < resultSize; e++) {
		result[e] = malloc(sizeof(sound));
		resultInt++;
		result[e]->samples = NULL;
	}
	dIndex = 0;
	int rIndex = 0;
	for (int e = 1; e < k; e++) {
		if (data[e]->length < data[e - 1]->length) {
			rSize = data[e - 1]->length;
			dIndex = data[e]->length;
		}
		else {
			rSize = data[e]->length;
			dIndex = data[e - 1]->length;
		}
		float* sizeTemp = malloc(sizeof(float) * rSize);
		float* compare;
		if (noteData[e].start_time == noteData[e - 1].start_time) {
			for (int o = 0; o < dIndex; o++) {
				sizeTemp[o] = data[e]->samples[o] + data[e - 1]->samples[o];
			}
			for (int o = dIndex; o < rSize; o++) {
				if (rSize == data[e]->length) {
					sizeTemp[o] = data[e]->samples[o];
				}
				else {
					sizeTemp[o] = data[e - 1]->samples[o];
				}
			}
			if (result[rIndex]->samples == NULL) {
				result[rIndex]->samples = sizeTemp;
				result[rIndex]->length = rSize;
				result[rIndex]->rate = data[e - 1]->rate;
			}
			else {
				int tempSize = 0;
				tempSize = rSize;
				if (result[rIndex]->length < rSize) {
					dIndex = result[rIndex]->length;
					result[rIndex]->length = rSize;
				}
				else {
					dIndex = rSize;
					rSize = result[rIndex]->length;
				}
				compare = malloc(sizeof(float) * rSize);
				compareInt++;
				for (int o = 0; o < dIndex; o++) {
					compare[o] = result[rIndex]->samples[o] + sizeTemp[o];
				}
				for (int o = dIndex; o < rSize; o++) {
					if (rSize != tempSize) {
						compare[o] = result[rIndex]->samples[o];
					}
					else {
						compare[o] = sizeTemp[o];
					}
				}
				result[rIndex]->samples = compare;
			}
		}
		else {
			sound* temp = malloc(sizeof(sound));
			float* floatTemp = malloc(sizeof(sound) * data[e - 1]->length);
			temp->length = data[e - 1]->length;
			temp->rate = data[e - 1]->rate;
			if (result[rIndex]->samples == NULL) {
				for (int i = 0; i < data[e - 1]->length; i++) {
					floatTemp[i] = data[e - 1]->samples[i];
				}
			}
			else {
				for (int i = 0; i < data[e - 1]->length; i++) {
					floatTemp[i] = data[e - 1]->samples[i] + result[rIndex]->samples[i];
				}
			}
			temp->samples = floatTemp;
			free(result[rIndex]->samples);
			free(result[rIndex]);
			result[rIndex] = temp;
			rIndex++;
			if (rIndex != 0) {
				if (noteData[e].start_time > noteData[e - 1].duration + noteData[e - 1].start_time) {
					float times = noteData[e].start_time - noteData[e - 1].duration - noteData[e - 1].start_time;
					sound* temp = genSilence(result[rIndex - 1]->rate, times);
					free(result[rIndex]);
					result[rIndex] = temp;
					rIndex++;
				}
			}
			if (e == k - 1) {
				free(result[rIndex]);
				sound* temp = malloc(sizeof(sound));
				float* floatTemp = malloc(sizeof(sound) * data[e]->length);
				temp->length = data[e]->length;
				temp->rate = data[e]->rate;
				for (int i = 0; i < data[e]->length; i++) {
					floatTemp[i] = data[e]->samples[i];
				}
				temp->samples = floatTemp;
				result[rIndex] = temp;
				rIndex++;
			}
		}
		free(sizeTemp);
	}

	for (int e = 0; e < resultSize; e++) {
		for (int w = 0; w < result[e]->length; w++) {
			printf("%f\n",result[e]->samples[w]);
		}
	}
	for (int i = 0; i < k; i++) {
		free(data[i]->samples);
		free(data[i]);
	}
	free(data);
	wave* cur;
	for (int e = 0; e < j + 1; e++) {
		wave* cur2;
		cur = ssongData[e].waveData;
		for (int p = 0; p < ssongData[e].size; p++) {
			cur2 = cur;
			if (cur->next != NULL) {
				cur = cur->next;
			}
			free(cur2);
		}
	}
	for (int e = 0; e < resultSize; e++) {
			free(result[e]->samples);
			free(result[e]);
	}
	free(result);
	free(songData);
	free(ssongData);
	free(noteData);
	return 0;
}

void sortArray(note* notes, int size) {
	note temp;
	for (int i = 0; i < size; i++) {
		for (int j = i; j < size; j++) {
			if (notes[i].start_time > notes[j].start_time) {
				temp = notes[i];
				notes[i] = notes[j];
				notes[j] = temp;
			}
		}
	}
}

int findIndex(int target, ssong* range, int size) {
	for (int i = 0; i < size; i++) {
		int nameSize = strlen(range->name);
		if (range[i].name[nameSize - 1] - '0' == target)
			return i;
	}
	return -1;
}
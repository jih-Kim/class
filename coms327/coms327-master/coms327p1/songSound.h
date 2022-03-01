#ifndef SONGSOUND_H_
#define SONGSOUND_H_

typedef struct songWave {
	char name[256];
	int type;			//0 for sine, 1 for square, 2 for triangle, 3 for saw
	float delay;
	float attenuation;
}song;
typedef struct wavemix {
	int waveIndex;
	float mixValue;
	struct wavemix* next;
}wave;

typedef struct songSound {
	char name[256];
	wave* waveData;
	int size;
}ssong;

typedef struct songNote {
	int soundIndex;
	float frequency;
	float start_time;
	float duration;
}note;
#endif
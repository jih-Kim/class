#ifndef SOUND_H_
#define SOUND_H_

typedef struct sound_t {
	float* samples;
	int length;
	float rate;
}sound;

#endif  /*SOUND_H_*/
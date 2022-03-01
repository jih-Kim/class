#include "iosnd.h"

int outputSound(sound* s, FILE* f) {
	if (f == NULL)
		return 1;
	for (int i = 0; i < s->length; i++) {
		fprintf(f, "%f\n", s->samples[i]);
	}
	return 0;
}
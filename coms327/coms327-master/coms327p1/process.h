#include "sound.h"

sound* mix(sound* s[], float w[], int c);
sound* modulate(sound* s1, sound* s2);
sound* filter(sound* s, float fir[], int c);
sound* reverb(sound* s, float delay, float attenuation);
sound* echo(sound* s, float delay, float attenuation);
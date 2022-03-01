# coms327p1

# Part c

There is four c file and five header file for this part.
The c file is gensnd.c, iosnd.c, playsong.c, process.c.
The header file is gensnd.h, iosnd.h, process.h, songSound.h, and sound.h

songSound.h and sound.h file have the struct data which uses in gensnd.c, process.c, and playsong.c
It have songWave which contains char[256] name, int type (0 for sine, 1 for square, 2 for traingle, 3 for saw), float delay, float attenuation.
It have wavemix which contains int waveIndex, float mixValue, struct wavemix* next
It have songSound which contains char[256] name, wave* waveData, int size
It have songNote which contains int soundIndex, float frequency, float start_time, float duration
It have sound which contains float* samples, int length, float rate

The gensnd.h file include the information about gensnd.c file.

gensnd.c :

sound* gensine(float hertz, float sample_rate, float duration)
    This method calculate the sin value of specific hertz, sample_rate, and duration.
    The method return the sound* which have sound information in it.
    @par - float hertz, float sample_rate, float duration
    @return - sound*
    
sound* genDTMF(char key, float sample_rate, float duration)
    This method calculate the sin value of the right key
    For example if key is 1, it returns the sound of 1's sin value.
    The method return the sound* which have sound information in it.
    @par - char key, float sample_rate, float duration
    @return - sound*
    
sound* saveSumOfSin(int firstHZ, int secondHZ)
    This method if helper method of genDTMF. It calculate the key's sin value.
    The method return the sound* which have sound information in it.
    @par - int firstHZ, int secondHZ
    @return - sound*
    
sound* genPhonePad(char entered)
    This method if helper method of genDTMF. It search for the right key and use saveSumOfSin and pass it to genDTMF.
    The method return the sound* which have sound information in it.
    @par - char entered
    @return - sound*
    
sound* genSilence(float sample_rate, float duration)
    This method calculate the silence value
    The method return the sound* which have sound information in it.
    @par - float sample_rate, float duration
    @return - sound*
    
sound* genSquare(float hertz, float sample_rate, float duration)
    This method calculate the value of specific hertz, sample_rate, and duration. The result of graph looks like Square which only have 1 or -1.
    The method return the sound* which have sound information in it.
    @par - float hertz, float sample_rate, float duration
    @return - sound*
    
sound* genTriangle(float hertz, float sample_rate, float duration)
    This method calculate the value of specific hertz, sample_rate, and duration. The result of graph looks like Triangle.
    The method return the sound* which have sound information in it.
    @par - float hertz, float sample_rate, float duration
    @return - sound*
    
sound* genSawtooth(float hertz, float sample_rate, float duration)
    This method calculate the value of specific hertz, sample_rate, and duration. The result of graph looks like Sawtooth.
    The method return the sound* which have sound information in it.
    @par - float hertz, float sample_rate, float duration
    @return - sound*
   
The iosnd.h file include the information about iosnd.c file.   
    
iosnd.c :

int outputSound(sound* s, FILE* f)
    This method output the sound samples that contain in the sound* and return 1 if there is error in file.
    @par - sound* s, FILE* f
    @return - int
  
The process.h file include the information about process.c 
  
process.c :
sound* mix(sound* s[], float w[], int c)
The method mix the multiple sound.
The method return the sound* which have sound information in it. The c is size of w.
 @par - sound* s[], float w[], int c
 @return - sound*

sound* modulate(sound* s1, sound* s2)
This method multiply two sound data.
@par - sound* s1, sound* s2
@return - sound*

sound* filter(sound* s, float fir[], int c)
This method calculate the filter sound using the s and fir. The c is size of fir.
@par - sound* s, float fir[], int c
@return - sound*

sound* reverb(sound* s, float delay, float attenuation)
This method calculate the s using the filter function. It output the error message if there is error.
@par - sound* s, float delay, float attenuation
@return - sound*

sound* echo(sound* s, float delay, float attenuation);
This method calculate the s using the filter function. It output the error message if there is error.
It is similar to reverb but the delay range is different than reverb.
@par - sound* s, float delay, float attenuation
@return - sound*

playsong.c :
This is main method to calculate the float data. It check the filename and output error message if it can't find the file and finish the main.
It uses the informatio in the file and calculate the right sound data using the method in process.c and gensnd.c
It have two helper method which is sortArray and findindex.

void sortArray(note* notes, int size)
This method sort the array so main can calculate easily.
The size is notes size.
@par - note* notes, int size

int findIndex(int target, ssong* range, int size)
This method find the indext of ssong data and return the index.
size is the size of ssong.
@par - int target, ssong* range, int size
@return - int index

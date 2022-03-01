# coms327p1

# Part a
Made three c file and one header file. There is two main because we need to test two cases. 

First main will show the one continuous sin values.

Second main will show the one continouse sin values, which are add by two different sin values.

First and second main uses one header file so it can uses the method in other c file.

<gensnd.c>

void gensine(float freq, float SR, float duration)

-calculate the sin value using freq(frequency), SR(Sample Rate), duration.


void printSumOfSin(int firstHZ, int secondHZ)

-calculate the sum of two sin value using each frequency. 

This two sin Sample Rate is fix as 8000 and duration is fix by 0.5 second.


void inputPhonePad(char entered)

-This method uses switch to check the char entered and brings the printSumOfSin with the right value. 

We already check the error in the main so we don't have to worry about error.


void silence(float sampleRate, float duration)

-This method output the 0 value using sampleRate and duration. 

This mean when this method is called it create silence and does not sound anything.


sound* gensine2(float hertz, float sample_rate, float duration)
-This method test if the data is correctly save. The calculation is same as gensine in part a.


Sound* saveSumOfSin(int firstHZ, int secondHZ)
-This method test if the sin data, which calculate the two other sin data, and save into sound* data.


sound* genPhonePad(char entered)
-This method call saveSumOfSin with right hertz. It checks the character entered and call the right hertz.


sound* genDTMF2(char key, float sample_rate, float duration)
-This method call genPhonePad with right key and sample_rate and duration.


sound* genSilence(flaot sample_rate, float duration)
-This method create the silence data which is 0. It is similar to silence in part a but it save the silence data in sound*


int outputSound(sound* s, FILE *f)
-This method save the sound data into the file. It return 0 if it succeed and return 1 if it fail to save it.
<main.c>

-This main is used for gensine which create the sin value. 

It uses the gensnd header file so this c file can uses method in gensnd c file.

This main method ask user to input three float value, which are frequency, sampleRate, and duration. 

Output the sin value corresponding to input.

<main2.c>

-This main is used for gendial which create the sin value of phone key. 

It uses the gensnd header file so this c file can uses method in gensnd c file.

This main method ask user to input 10 character. 

The character has to be 0~9 , * ,#, a,b,c,d. The alphabet can be upper and lower alphabet.

When user input wrong character or user input more than 10 character 

it will return error message and finish the program.


<main1b.c>
-This main test the part b. It test if the data is calculate correctly and save into file if there is file name. It input the 10 digit number and create sound wave which relate to that number
 
 It return error message if there is no or less string command when using this file.Also it checks if the number that user input is right input or not and return error message if there is missing part.
 
 When the program find the error it simply finish the program. So user have to restart this program with right input.
 
 This file create dtmf which save the sin value to file or output the sin value.
 
 It work similar as main2.c but it save the data using struct sound.
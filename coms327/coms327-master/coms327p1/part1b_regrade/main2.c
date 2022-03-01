/*
 * This include line basically imports the stdio header file, part of the standard library, and gensnd header file, which provide the inputPhonepad method and silence method. The stdio header file provide input and output functionality to the program.
 * */
#include <stdio.h>
#include "gensnd.h"

/*
 * This main method test the phnepad, which gives result of sin value, when user input 10 digit phoneNumber. The user have to type 10 difit phonenumber at one time. Silence method gives 0 value between the number sin value If user put wrong input or too long input it will gives error and end the program.
 * */
int main(void) {

	char phoneNumber[100];
	scanf("%s", &phoneNumber);
	if(phoneNumber[10]!='\0'||phoneNumber[9] == '?')
	{
	    printf("Invalid input : it is too long. Please check your input and start again\n");
	    return 0;
	}
	    for (int i=0; i < 10; i++)
	{
	    if(phoneNumber[i]=='1' || phoneNumber[i]=='2' || phoneNumber[i]=='3' || phoneNumber[i]=='4' || phoneNumber[i]=='5' 
	    || phoneNumber[i]=='6' || phoneNumber[i]=='7' || phoneNumber[i]=='8' || phoneNumber[i]=='9' || phoneNumber[i]=='0' 
	    || phoneNumber[i]=='A' || phoneNumber[i]=='a' || phoneNumber[i]=='B' || phoneNumber[i]=='b' || phoneNumber[i]=='C' 
	    || phoneNumber[i]=='c' || phoneNumber[i]=='D' || phoneNumber[i]=='d')
	    {
	        
	    }
	    else
	    {
	        printf("Invalid input: Please check your input and start again\n");
	        return 0;
	    }
	}
	for (int i = 0; i < 10; i++)
	{
		char temp = phoneNumber[i];
		inputPhonePad(temp);
		if(i!=9)
		silence(8000, 0.25);
	}
	
	return 0;
}

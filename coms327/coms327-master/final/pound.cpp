#include "pound.h"

/*
* default constructor for pound. It saves the typename as pound automatically
*/
pound::pound(){
}

/*
* Total method to find the total price in candy.
*/
float pound::Total() {
	return getAmount()* getPrice() / 16;
}
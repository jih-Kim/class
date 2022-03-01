#include "piece.h"

/*
* default constructor of piece class. It saves the typeName as piece when it call the constructor
*/
piece::piece(){
}

/*
* The method calculate the total amount of the candy.
*/
float piece::Total(){
	return getAmount()* getPrice();
}



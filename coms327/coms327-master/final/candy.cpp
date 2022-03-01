#include "candy.h"
#include <iostream>

using namespace std;

/*
* default constructor for candy class.
*/
candy::candy() {
	candyName = "";
	typeName = "";
	price = 0;
	color = 0;
	amount = 0;
	calories = 0;
}

/*
* constructor with value for candy class
*/
candy::candy(string cname, string tname, float p, int c, float a, float ca) {
	candyName = cname;
	typeName = tname;
	price = p;
	color = c;
	amount = a;
	calories = ca;
}

/*
* destructors for candy class
* Since we don't use any array we don't do anything in destructors
*/
candy::~candy() {

}

/*
* copy constructor for candy class. It deeps copy the candy b.
*/
candy::candy(const candy& b) {
	candyName = b.candyName;
	typeName = b.typeName;
	price = b.price;
	color = b.color;
	amount = b.amount;
	calories = b.calories;
}

/*
* overloaded operators =
*/
candy& candy::operator = (candy const &b) {
	candyName = b.candyName;
	typeName = b.typeName;
	price = b.price;
	color = b.color;
	amount = b.amount;
	calories = b.calories;
	return *this;
}

/*
* getter method for candy name
*/
string candy::getCandyName() {
	return candyName;
}

/*
* setter method for candy name
*/
void candy::setCandyName(string cn) {
	candyName = cn;
}

/*
* getter method for typename
*/
string candy::getTypeName() {
	return typeName;
}

/*
* setter method for typename
*/
void candy::setTypeName(string tn) {
	typeName = tn;
}

/*
* getter method for price
*/
float candy::getPrice() {
	return price;
}

/*
* setter method for price
*/
void candy::setPrice(float p) {
	price = p;
}

/*
* getter method for color
*/
int candy::getColor() {
	return color;
}

/*
* setter method for color
*/
void candy::setColor(int c) {
	color = c;
}

/*
* getter method for amount
*/
float candy::getAmount() {
	return amount;
}

/*
* setter method for amount
*/
void candy::setAmount(float am) {
	amount = am;
}

/*
* getter method for calories
*/
float candy::getCalories() {
	return calories;
}

/*
* setter method for calories
*/
void candy::setCalories(float ca) {
	calories = ca;
}

/*
* getter method for typeName
*/
string candy::getType() {
	return priceType;
}

/*
* setter method for typeName
*/
void candy::setType(string t) {
	priceType = t;
}


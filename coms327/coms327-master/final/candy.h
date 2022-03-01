#pragma once
#include <iostream>
using namespace std;

/*
Header file for candy. Save the candyName, typeName, price, color, amount, calories
The data is not used in the main however the main saves the data and keep it.
The price type is saved by subclasses which is  piece.cpp and pound.cpp.
*/
class candy {
public :
	candy();
	candy(string cname, string tname, float p, int c, float a, float ca);
	~candy();
	candy(const candy& b);
	candy& operator = (const candy& b);
	string getCandyName();
	void setCandyName(string cn);
	string getTypeName();
	void setTypeName(string tn);
	//int getPT();
	//void setPT(int pt);
	float getPrice();
	void setPrice(float p);
	int getColor();
	void setColor(int c);
	float getAmount();
	void setAmount(float am);
	float getCalories();
	void setCalories(float ca);
	string getType();
	void setType(string t);
	virtual float Total() = 0;

private :
	string candyName;
	string typeName;
	string priceType;
	float price;
	int color;
	float amount;
	float calories;
};
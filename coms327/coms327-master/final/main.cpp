#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include "candy.h"
#include "piece.h"
#include "pound.h"
using namespace std;

/*
reading the input file and returns the following
1. A list of all candies that includes the name, the amount on hand in the store, and the total price of the each item's current inventory
2. A summary line that prints the total value of candy in all inventory in the store
3. The total number of different types of candy. (jelly, caramel, chocolate, hard)
*/
int main() {
	string oneData;
	string name;
	string type;
	float price;
	int color;
	float amount;
	float calories;
	int size = 0;
	ifstream file("data.txt");
	float totalValue = 0;
	int chocoNum = 0;
	int jellyNum = 0;
	int caraNum = 0;
	int hardNum = 0;
	vector<candy*> alldata;
	candy *temp;
	bool start = 0;
	while (getline(file, oneData)) {
		if (oneData == "START") {
			start = 1;
		}
		if (oneData == "END") {
			start = 0;
		}
		if (start == 1) {
			getline(file, name);
			getline(file, type);
			if (type == "chocolate")
				chocoNum++;
			if (type == "jelly")
				jellyNum++;
			if (type == "caramel")
				caraNum++;
			if (type == "hard")
				hardNum++;
			getline(file, oneData);
			if (oneData == "piece") {
				temp = new piece();
			}
			else
			{
				temp = new pound();
			}
			getline(file, oneData);
			price = stof(oneData);
			getline(file, oneData);
			color = stoi(oneData);
			getline(file, oneData);
			amount = stof(oneData);
			getline(file, oneData);
			calories = stof(oneData);

			temp->setCandyName(name);
			temp->setTypeName(type);
			temp->setPrice(price);
			temp->setColor(color);
			temp->setAmount(amount);
			temp->setCalories(calories);
			totalValue = totalValue + temp->Total();
			
			//sorting part
			int index = -1;
			for (int i = 0; i < alldata.size(); i++) {
				if (alldata.at(i)->Total() < temp->Total()) {
					index = i; //this index is where you store the data
					break;
				}
			}
			alldata.push_back(temp);
			if (index != -1) {
				for (int i = alldata.size() - 1; i > index; i--) {
					candy* t = alldata.at(i);
					alldata.at(i) = alldata.at(i - 1);
					alldata.at(i - 1) = t;
				}
			}
		}
	}

	for (int i = 0; i < alldata.size(); i++) {
		cout << alldata.at(i)->getCandyName() << " l " << alldata.at(i)->getAmount() << " l " << alldata.at(i)->Total() << endl;
	}
	cout << endl;
	cout << "total value of candy in store : " << totalValue << endl;
	cout << endl;
	cout << "number of jelly : " << jellyNum << endl;
	cout << "number of caramel : " << caraNum << endl;
	cout << "number of chocolate : " << chocoNum << endl;
	cout << "number of hard : " << hardNum << endl;

}

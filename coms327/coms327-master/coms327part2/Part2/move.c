#define _CRT_SECURE_NO_WARNINGS
#include "readFile.h"
#include <string.h>
#include <stdio.h>

int StockToWaste(char c, char c2, char** data);
int WasteToFoundationOrTableau(char c1, char c2, char** data, int* dataSize);
int callRead();
int checkCard(char** dataTotal, char a, int* dataSize);
int executeMove(char** dataTotal, int* dataSize);
int findIndex(char a);
int getInteger(char num);
int moveTableau(char** dataTotal, char a, char b, int* dataSize);
void printTableau(char** data, int* dataSize);
int saveFoundation(char** dataTotal, int* dataSize, char num, char shape, int times);
int saveTableau(char** dataTotal, int* dataSize, char a, char num, char shape, int check);
void showData(char** data, int* dataSize);

int callRead() {
	mainRead();
	return 0;
}

int executeMove(char** dataTotal, int* dataSize)
{
	int j = 0;
	//int size = dataSize[9];
	//char temp = dataTotal[9][size - 2];
	//Eliminate(dataTotal[9], temp, size-3);
	//dataSize[9]--;
	char* data = dataTotal[9];
	
	int result = 0;
	int check = 0; //check if it works or not
	int noError = 0; //check if there is error or not
	int countMove = 0; //count the move execute
	while (data[j] != '\n')
	{
		//if (data[j] == '-' || data[j] == '.' || data[j] == 'r')
		//{
		//	for (int i = 0; i < 10; i++)
		//	{
		//		printf("%s\n", dataTotal[i]);
		//	}
		//	printf("___________________________________________\n");
		//	
		//}
		//if(data[j]=='-')
		//	printf("%c -> %c\n", data[j - 1], data[j + 1]);
		//if(data[j]=='.'||data[j]=='r')
		//	printf("%c\n", data[j]);
		//
		if (data[j] == '-')
		{
			if (data[j - 1] == 'w') //w -> t || w -> f
			{
				check = WasteToFoundationOrTableau(data[j - 1], data[j + 1], dataTotal, dataSize);
				countMove++;
				if (check == 0)
				{
					printf("Move %d is Illegel : %c -> %c\n", countMove, data[j - 1], data[j + 1]);
					noError = 1;
				}
			}
			else // t -> t || t -> f
			{
				check = moveTableau(dataTotal, data[j - 1], data[j + 1], dataSize);
				countMove++;
				if (check == 0)
				{
					printf("Move %d is Illegel : %c -> %c\n", countMove, data[j - 1], data[j + 1]);
					noError = 1;
				}
			}
		}
		if (data[j] == '.' || data[j] == 'r')
		{
			check = StockToWaste(getTurns(), data[j], dataTotal);
			countMove++;
			if (check == 0)
			{
				printf("Move %d is Illegel : %c\n", countMove, data[j]);
				noError = 1;
			}
		}
		j = j++;
		result = result + check;
		check = 0;
	}
	if (noError == 0)
	{
		printf("Processed %d moves , all valid\n", countMove);
	}
	return result;
}
int findIndex(char a)
{
	switch (a)
	{
	case '1':
		return 2;
		break;
	case '2':
		return 3;
		break;
	case '3':
		return 4;
		break;
	case '4':
		return 5;
		break;
	case '5':
		return 6;
		break;
	case '6':
		return 7;
		break;
	default:
		return 8;
	}
}

//return 1 if it succeed else return 0
int moveTableau(char** dataTotal, char a, char b, int* dataSize)
{
	char num;
	char shape;
	char* data;
	int index = findIndex(a);
	int times = checkCard(dataTotal, a, dataSize);
	int Size = dataSize[index];
	data = dataTotal[index];
	int index2 = 0;
	int temp = 0;
	for (int i = 0; i < Size; i++)
	{
		if (data[i] == '|')
			index2 = i;
	}
	if (b == 'f')
	{
			num = data[dataSize[index] - 2];
			shape = data[dataSize[index]-1];
			if (b == 'f')
			{
				//1 succeed 0 error
				temp = temp + saveFoundation(dataTotal, dataSize, num, shape, times);
				if(temp==0)
					printf("Error! Foundation Number Error!\n");
			}
			Eliminate(data, num, dataSize[index] - 3);
			dataSize[index]--;
			Eliminate(data, shape, dataSize[index] - 2);
			dataSize[index]--;
			if (data[dataSize[index] - 1] == '|' && !(dataSize[index] == 1))
			{
				data[dataSize[index] - 1] = data[dataSize[index] - 2];
				data[dataSize[index] - 2] = data[dataSize[index] - 3];
				data[dataSize[index] - 3] = '|';
			}
		if (temp > 0)
			return 1;
		else
			return 0;
	}
	else
	{
		for (int i = times; i > 0; i--)
		{
			num = data[Size - 2 * times];
			shape = data[Size - 2 * times + 1];
			Eliminate(data, num, index2);
			dataSize[index]--;
			Eliminate(data, shape, index2);
			dataSize[index]--;
			if (data[dataSize[index] - 1] == '|' && !(dataSize[index] == 1))
			{
				data[dataSize[index] - 1] = data[dataSize[index] - 2];
				data[dataSize[index] - 2] = data[dataSize[index] - 3];
				data[dataSize[index] - 3] = '|';
			}
				//1 succeed 0 error
			temp = temp + saveTableau(dataTotal, dataSize, b, num, shape, i + 1);
			//Size = dataSize[index];
		}
		if (temp == times)
			return 1;
		else
			return 0;
	}
	


}
int getInteger(char num)
{
	if (num == 'A')
		return 1;
	else if (num == 'T')
		return 10;
	else if (num == 'J')
		return 11;
	else if (num == 'Q')
		return 12;
	else if (num == 'K')
		return 13;
	else if (num == '_')
		return -1;
	else
		return num - 48;
}


int WasteToFoundationOrTableau(char c1, char c2, char** data, int* dataSize) {

	int locationOfBar = 0;
	for (unsigned int i = 0; i < getStockSize(); i++) {

		if (data[1][i] == '|') {
			break;
		}
		locationOfBar++;
	}

	int sizeWithOutWasteCard = dataSize[1] - 2;
	char tempCardInfo[2] = { "00" };
	tempCardInfo[0] = data[1][locationOfBar - 2];
	tempCardInfo[1] = data[1][locationOfBar - 1];

	if (c1 == 'w') {

		if (locationOfBar == 0) {
			return 0;
		}
		else {
			for (unsigned int i = locationOfBar; i < dataSize[1]; i++) {
				data[1][i - 1] = data[1][i];
				data[1][i] = data[1][i + 1];
			}

			dataSize[1] --;

			locationOfBar--;

			for (unsigned int i = locationOfBar; i < dataSize[1]; i++) {
				data[1][i - 1] = data[1][i];
				data[1][i] = data[1][i + 1];
			}

			dataSize[1] --;



		}

		if (c2 == 'f') {
			switch (tempCardInfo[1]) {
			case 'c':
				if (helpMethod(data[0][0]) + 1 == helpMethod(tempCardInfo[0])) {
					data[0][0] = tempCardInfo[0];
					return 1;
					break;
				}
				else {
					printf("The number is not match in waste to founation part\n");
					return 0;
					break;
				}
			case 'd':
				if (helpMethod(data[0][2]) + 1 == helpMethod(tempCardInfo[0])) {
					data[0][2] = tempCardInfo[0];

					return 1;
					break;
				}
				else {
					printf("The number is not match in waste to founation part\n");
					return 0;
					break;
				}
			case 'h':
				if (helpMethod(data[0][4]) + 1 == helpMethod(tempCardInfo[0])) {
					data[0][4] = tempCardInfo[0];

					return 1;
					break;
				}
				else {
					printf("The number is not match in waste to founation part\n");
					return 0;
					break;
				}
			case 's':
				if (helpMethod(data[0][6]) + 1 == helpMethod(tempCardInfo[0])) {
					data[0][6] = tempCardInfo[0];

					return 1;
					break;
				}
				else {
					printf("The number is not match in waste to founation part\n");
					return 0;
					break;
				}
			}
		}
		else {
			int temp = (int)c2 - 48;
			temp += 1;

			//Remove one !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			int location = dataSize[temp];
			location -= 1; //-1 



			if (location == 0) {
				if (helpMethod(tempCardInfo[0]) == 13) {
					data[temp][location + 1] = tempCardInfo[0];
					data[temp][location + 2] = tempCardInfo[1];
					dataSize[temp] ++;
					dataSize[temp] ++;
					return 1;
				}
				else {
					printf("Error : the selected card is not King\n");
					return 0;
				}
			}
			else {
				if (data[temp][location] == 'c' || data[temp][location] == 's') {
					if (tempCardInfo[1] == 'd' || tempCardInfo[1] == 'h') {
						if (helpMethod(data[temp][location - 1]) - 1 == helpMethod(tempCardInfo[0])) {
							data[temp][location + 1] = tempCardInfo[0];
							data[temp][location + 2] = tempCardInfo[1];
							dataSize[temp] ++;
							dataSize[temp] ++;
							return 1;
						}
						else {
							printf("card number is not match\n");
							return 0;
						}
					}
					else {
						printf("card color is not match\n");
						return 0;
					}
				}
				else if (data[temp][location] == 'd' || data[temp][location] == 'h') {
					if (tempCardInfo[1] == 'c' || tempCardInfo[1] == 's') {
						if (helpMethod(data[temp][location - 1]) - 1 == helpMethod(tempCardInfo[0])) {
							data[temp][location + 1] = tempCardInfo[0];
							data[temp][location + 2] = tempCardInfo[1];
							dataSize[temp] ++;
							dataSize[temp] ++;
							return 1;
						}
						else {
							printf("card number is not match\n");
							return 0;
						}
					}
					else {
						printf("card color is not match\n");
						return 0;
					}
				}
				else {
					printf("this is error : not 'f' and 'index of colum', maybe other alphabet\n");
					return 0;
				}
			}
		}
	}
	else {
		printf("this is error : not 'w', maybe other alphabet\n");
		return 0;
	}
	return 0;
}


// read!!!!
// there is one Malloc : temmpArr <- need to use free method
int StockToWaste(char c, char c2, char** data) {

	int locationOfBar = 0;
	for (unsigned int i = 0; i < getStockSize(); i++) {

		if (data[1][i] == '|') {
			break;
		}
		locationOfBar++;
	}

	if (c == '1') {
		if (c2 == '.') {
			if (data[1][locationOfBar + 1] != '!') {
				char temp1 = data[1][locationOfBar + 1];
				char temp2 = data[1][locationOfBar + 2];
				data[1][locationOfBar] = temp1;
				data[1][locationOfBar + 1] = temp2;
				data[1][locationOfBar + 2] = '|';
				return 1;
			}
		}
		else if (c2 == 'r') {
			if (data[1][locationOfBar + 1] == '!') {

				char* tempArr = malloc(locationOfBar * sizeof(char));

				for (unsigned int i = 0; i < locationOfBar; i++) {
					tempArr[i] = data[1][i];
				}

				data[1][0] = '|';

				for (unsigned int i = 0; i < locationOfBar; i++) {
					data[1][i + 1] = tempArr[i];
				}
				return 1;

			}
		}
	}
	else if (c == '3') {

		int countBetweenBarAndExclamation = 0;
		for (unsigned int i = locationOfBar; i < getStockSize; i++) {

			if (data[1][i] == '!') {
				break;
			}

			countBetweenBarAndExclamation++;
		}

		if (c2 == '.') {
			if (countBetweenBarAndExclamation >= 6) {
				char temp[6];
				for (unsigned int i = 0; i < 6; i++) {
					temp[i] = data[1][locationOfBar + i + 1];
				}
				data[1][locationOfBar + 6] = '|';

				for (unsigned int i = 0; i < 6; i++) {
					data[1][locationOfBar + i] = temp[i];
				}
				return 1;
			}
			else if (countBetweenBarAndExclamation == 5) {
				char temp[4];
				for (unsigned int i = 0; i < 4; i++) {
					temp[i] = data[1][locationOfBar + i + 1];
				}

				data[1][locationOfBar + 4] = '|';

				for (unsigned int i = 0; i < 4; i++) {
					data[1][locationOfBar + i] = temp[i];
				}
				return 1;
			}
			else if (countBetweenBarAndExclamation == 3) {
				char temp[2];
				for (unsigned int i = 0; i < 2; i++) {
					temp[i] = data[1][locationOfBar + i + 1];
				}

				data[1][locationOfBar + 2] = '|';

				for (unsigned int i = 0; i < 2; i++) {
					data[1][locationOfBar + i] = temp[i];
				}
				return 1;
			}
		}
		else if (c2 == 'r') {
			if (countBetweenBarAndExclamation == 1) {
				char* tempArr = malloc(locationOfBar * sizeof(char));

				for (unsigned int i = 0; i < locationOfBar; i++) {
					tempArr[i] = data[1][i];
				}

				data[1][0] = '|';

				for (unsigned int i = 0; i < locationOfBar; i++) {
					data[1][i + 1] = tempArr[i];
				}
				return 1;
			}
		}
	}
	else {
		printf("Invalid form at Rules turn\n");
		return 0;
	}

	return 0;
}

void printTableau(char** data, int* dataSize) {

	char tempPrintTableau[7][100];

	//compare with line has long size
	int longSize = dataSize[2];

	for (unsigned int i = 3; i < 9; i++) {
		if (longSize <= dataSize[i]) {
			longSize = dataSize[i];
		}
	}
	longSize -= 2;

	int indexline = 0;
	while (indexline != 7) {

		int indexofBar = 0;
		for (unsigned int i = 0; i < 100; i++) {
			if (data[indexline + 2][i] == '|') {
				break;
			}
			indexofBar++;
		}

		for (unsigned int i = 0; i < indexofBar; i++) {
			tempPrintTableau[indexline][i] = '#';
		}
		indexofBar += 1;

		int temp1111 = dataSize[indexline + 2];

		for (unsigned int i = indexofBar; i < dataSize[indexline + 2]; i++) {
			tempPrintTableau[indexline][i - 1] = data[indexline + 2][i];
			/*		if (i == 1) {
						break;
					}
					else {
						tempPrintTableau[indexline][i - 1] = data[indexline + 2][i];
					}*/

		}

		//dataSize --1 
		if (dataSize[indexline + 2] == 2) {
			for (unsigned int i = 0; i < 100; i++) {
				tempPrintTableau[indexline][i] = '.';
			}
		}
		else {
			for (unsigned int i = dataSize[indexline + 2]; i < 100; i++) {
				tempPrintTableau[indexline][i - 1] = '.';
			}
		}



		indexline++;
	}




	for (unsigned int i = 0; i < longSize; i += 2) {

		int end = 0;

		for (unsigned int j = 0; j < 7; j++) {
			if (end != 6) {
				printf("%c%c ", tempPrintTableau[j][i], tempPrintTableau[j][i + 1]);
			}
			else if (end == 6) {
				printf("%c%c\n", tempPrintTableau[j][i], tempPrintTableau[j][i + 1]);
			}

			end++;
		}
	}
}

int checkCard(char** dataTotal, char a, int* dataSize)
{
	int index = findIndex(a);
	int result = 1;
	char* data = dataTotal[index];
	for (int i = dataSize[index] - 1; i > 1; i = i - 2)
	{
		if (data[i] == '|')
			i--;
		if (data[i] == 'h' || data[i] == 'd')
		{
			if (data[i - 2] == 'h' || data[i - 2] == 'd')
			{
				printf("Error! Same shape!\n");
				return result;
			}
		}
		if (data[i] == 'c' || data[i] == 's')
		{
			if (data[i - 2] == 'c' || data[i - 2] == 's')
			{
				printf("Error! Same shape!\n");
				return result;
			}
		}
		if (getInteger(data[i - 1]) + 1 != getInteger(data[i - 3]))
			return result;
		result++;
	}
	return result;
}


int saveTableau(char** dataTotal, int* dataSize, char a, char num, char shape, int check)
{
	char* temp;
	char* data;
	int index = findIndex(a);
	data = dataTotal[index];
	if (data[dataSize[index] - 1] == '|')
	{
		if (num == 'K')
		{
			data[dataSize[index]] = num;
			dataSize[index]++;
			data[dataSize[index]] = shape;
			dataSize[index]++;
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		data[dataSize[index]] = num;
		dataSize[index]++;
		data[dataSize[index]] = shape;
		dataSize[index]++;
		return 1;
	}
	
}


int saveFoundation(char** dataTotal, int* dataSize, char num, char shape, int times)
{
	char* data = dataTotal[0];
	int index = -1;
	for (int i = 0; i < dataSize[0]; i++)
	{
		if (data[i] == shape)
			index = i;
	}
	int right = getInteger(num);
	int left = getInteger(data[index - 1]);
	if (data[index - 1] == '_')
	{
		if (right != 1)
		{
			return 0;
		}
		data[index - 1] = num;
		return 1;
	}
	if (left + 1 != right)
	{
		return 0;
	}
	else
	{
		data[index - 1] = num;
		return 1;
	}
}
void showData(char** data, int* dataSize)
{
	printf("Foundations\n");
	for (int i = 0; i < dataSize[0] - 2; i = i + 2)
	{
		if (i == dataSize[0] - 3)
			printf("%c%c\n", data[0][i], data[0][i + 1]);
		else
			printf("%c%c ", data[0][i], data[0][i + 1]);

	}
	printf("Tableau\n");
	printTableau(data, dataSize);
	printf("Waste top\n");
	for (int i = 0; i < dataSize[1]; i++)
	{
		if (data[1][0] == '|')
		{
			printf("(empty)");
			break;
		}
		if (data[1][i] == '|')
			printf("%c%c\n", data[1][i - 2], data[1][i - 1]);
	}
}

int main() {
	callRead();
	char** data;
	int* dataSize;
	data = (char**)malloc(sizeof(char*) * 10);
	getData(data);
	dataSize = malloc(sizeof(int) * 10);
	getDataSize(dataSize);

	//for (int i = 0; i < 10; i++)
	//{
	//	printf("%s\n", data[i]);
	//}
	//for (int i = 0; i < 10; i++)
	//{
	//	printf("%d\n", dataSize[i]);
	//}
	executeMove(data, dataSize);

	//for (int i = 0; i < 10; i++)
	//{
	//	printf("%s\n", data[i]);
	//}
	showData(data, dataSize);

	return 0;
}


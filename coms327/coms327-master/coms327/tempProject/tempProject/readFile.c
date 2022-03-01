#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>



struct dataSave {
	char rulesList[2];
	//char foundationsList[4];
	//int countCoverdList;
	//int countOpenedList;
	//int countStockList;
	//int countWasteList;
	int clist[13];
	int dlist[13];
	int hlist[13];
	int slist[13];
};


void Eliminate(char* str, char ch);
void openFile();
void convertToLineData();
void makeBoolean(int i);
void SeperateData(int i);

int checkTheTable(char var[], int size);


char* foundationsArr(char line[]);
char* tableauCount(char line[]);
char* stockCount(char line[]);

int helpMethod(char ch);
void printDuplicateCard(int clist[], int dlist[], int hlist[], int slist[]);
void printMissingcard(int clist[], int dlist[], int hlist[], int slist[]);
int duplicateAndMissCard(int num[]);

void SettingTableCheck();


//global variable
char stockArr[2];
char tableArr[2];
char foundArr[2];
char foundationsList[4];
int countCoverdList;
int countOpenedList;
int countStockList;
int countWasteList;
char filename[100];
FILE* fp;
char gameTurns = '$';	//rule data
char gameLimit = '$';	//rule data
char foundations[100];	//foundation data
char tableau[100];	//tableau data
char stock[100];		//stock data
char moves[1000];		//move data
char data[1][100];	//line data from origin
char RString[6] = { "RULES:" };
char TurnString[5] = { "turn " };
char lString[6] = { "limit " };
char unlimit[9] = { "unlimited" };
char FString[12] = { "FOUNDATIONS:" };
char TString[8] = { "TABLEAU:" };
char SString[6] = { "STOCK:" };
char MString[6] = { "MOVES:" };
int Frule = 0;
int Ffound = 0;
int Ftable = 0;
int Fstock = 0;
int Fmoves = 0;
int FoundationSize = 0;
int tabluSize = 0;
int stockSize = 0;
int moveSize = 0;
int FMove = 0;
char num[21] = { "123456789TJKQA_hsdc|" };
int size = 0;
int JChange = 0;
char linedata[100][100];
struct dataSave ds;
char firstLine[30];
char secondLine[30];
char thridLine[30];
char fourLine[30];
char fiveLine[30];
char sixLine[30];
char sevenLine[30];
int openCard = 0;
int line = 0;
int FirstSize = 0;
int SecondSize = 0;
int ThreeSize = 0;
int FourSize = 0;
int FiveSize = 0;
int SixSize = 0;
int SevenSize = 0;
int checkError = 0;
char dataReturn[10];


void Eliminate(char* str, char ch, int start)
{
	int i = 0;
	for (; *str != '\0'; str++)
	{
		if (*str == ch && i > start)
		{
			strcpy(str, str + 1);
			str--;
		}
		i++;
	}
}
void getData(char** data)
{
	//data[0] = (char*)malloc(sizeof(char) * FoundationSize);
	data[0] = foundations;
	//data[1] = (char*)malloc(sizeof(char) * stockSize);
	data[1] = stock;
	//data[2] = (char*)malloc(sizeof(char) * FirstSize);
	data[2] = sevenLine;
	Eliminate(data[2], '@', 0);
	SevenSize--;
	//data[3] = (char*)malloc(sizeof(char) * SecondSize);
	data[3] = sixLine;
	Eliminate(data[3], '@', 0);
	SixSize--;
	//data[4] = (char*)malloc(sizeof(char) * ThreeSize);
	data[4] = fiveLine;
	Eliminate(data[4], '@', 0);
	FiveSize--;
	//data[5] = (char*)malloc(sizeof(char) * FourSize);
	data[5] = fourLine;
	Eliminate(data[5], '@', 0);
	FourSize--;
	//data[6] = (char*)malloc(sizeof(char) * FiveSize);
	data[6] = thridLine;
	Eliminate(data[6], '@', 0);
	ThreeSize--;
	//data[7] = (char*)malloc(sizeof(char) * SixSize);
	data[7] = secondLine;
	Eliminate(data[7], '@', 0);
	SecondSize--;
	//data[8] = (char*)malloc(sizeof(char) * SevenSize);
	data[8] = firstLine;
	Eliminate(data[8], '@', 0);
	FirstSize--;
	//data[9] = (char*)malloc(sizeof(char) * moveSize);
	data[9] = moves;

}

char getTurns() {
	return gameTurns;
}

char getLimit() {
	return gameLimit;
}

int getStockSize() {
	return stockSize;
}

/*
0 - foundation
1 - stock
2 - firstline
3 - secondline
4 - thirdline
5 - fourline
6 - fiveline
7 - sixline
8 - sevenline
9 - move
*/
void getDataSize(int* dataSize)
{
	dataSize[0] = FoundationSize;
	dataSize[1] = stockSize;
	dataSize[2] = SevenSize;
	dataSize[3] = SixSize;
	dataSize[4] = FiveSize;
	dataSize[5] = FourSize;
	dataSize[6] = ThreeSize;
	dataSize[7] = SecondSize;
	dataSize[8] = FirstSize;
	dataSize[9] = moveSize;
}


int mainRead()
{
	openFile();
	convertToLineData();
	for (int i = 0; i < size; i++)
	{
		makeBoolean(i);
		if (linedata[i][0] == '\n')
			break;
		SeperateData(i);
	}
	foundations[FoundationSize] = '!';
	FoundationSize++;
	tableau[tabluSize] = '!';
	tabluSize++;
	stock[stockSize] = '!';
	stockSize++;
	//printf("turns : %c\n", gameTurns);
	//printf("limit : %c\n", gameLimit);
	//printf("foundation : %s\n", foundations);
	//printf("tableau : %s\n", tableau);
	//printf("stock : %s\n", stock);
	//printf("FINSISH SAVING\n");

	//DW code!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	char* temp1 = foundationsArr(foundations);
	char* temp2 = stockCount(stock);
	char* temp3 = tableauCount(tableau);

	for (int i = 0; i < 4; i++)
	{

		foundationsList[i] = foundationsArr(foundations)[i];
	}
	countCoverdList = tableauCount(tableau)[0];
	countOpenedList = tableauCount(tableau)[1];
	countStockList = stockCount(stock)[0];
	countWasteList = stockCount(stock)[1];

	//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD&&&&&&&&&&&&&&&&&&&&&&&&MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

	for (int i = 0; i < 13; i++) {
		ds.clist[i] = 0;
		ds.dlist[i] = 0;
		ds.hlist[i] = 0;
		ds.slist[i] = 0;
	}

	for (int i = 0; i < helpMethod(foundationsList[0]); i++) {
		ds.clist[i] = 1;
	}
	for (int i = 0; i < helpMethod(foundationsList[1]); i++) {
		ds.dlist[i] = 1;
	}
	for (int i = 0; i < helpMethod(foundationsList[2]); i++) {
		ds.hlist[i] = 1;
	}
	for (int i = 0; i < helpMethod(foundationsList[3]); i++) {
		ds.slist[i] = 1;
	}

	int std1 = 0;
	int std2 = 0;

	for (int i = 0; i < 100; i++) {
		if (tableau[i] == '!') {
			std1 = i;
		}
	}
	for (int i = 0; i < 100; i++) {
		if (stock[i] == '!') {
			std2 = i;
		}
	}

	for (int i = 0; i < std1; i++) {
		if (tableau[i] == 'c') {
			for (int j = 0; j < 13; j++) {
				if (j == (helpMethod(tableau[i - 1]) - 1)) {
					ds.clist[j]++;
				}
			}
		}
		else if (tableau[i] == 'd') {
			for (int j = 0; j < 13; j++) {
				if (j == (helpMethod(tableau[i - 1]) - 1)) {
					ds.dlist[j]++;
				}
			}
		}
		else if (tableau[i] == 'h') {
			for (int j = 0; j < 13; j++) {
				if (j == helpMethod(tableau[i - 1]) - 1) {
					ds.hlist[j]++;
				}
			}
		}
		else if (tableau[i] == 's') {
			for (int j = 0; j < 13; j++) {
				if (j == helpMethod(tableau[i - 1]) - 1) {
					ds.slist[j]++;
				}
			}
		}
	}

	for (int i = 0; i < std2; i++) {
		if (stock[i] == 'c') {
			for (int j = 0; j < 13; j++) {
				if (j == helpMethod(stock[i - 1]) - 1) {
					ds.clist[j]++;
				}
			}
		}
		else if (stock[i] == 'd') {
			for (int j = 0; j < 13; j++) {
				if (j == helpMethod(stock[i - 1]) - 1) {
					ds.dlist[j]++;
				}
			}
		}
		else if (stock[i] == 'h') {
			for (int j = 0; j < 13; j++) {
				if (j == helpMethod(stock[i - 1]) - 1) {
					ds.hlist[j]++;
				}
			}
		}
		else if (stock[i] == 's') {
			for (int j = 0; j < 13; j++) {
				if (j == helpMethod(stock[i - 1]) - 1) {
					ds.slist[j]++;
				}
			}
		}
	}

	//for (int i = 0; i < 13; i++) {
	//	printf("%d ", ds.clist[i]);
	//}
	//printf("\n");

	//for (int i = 0; i < 13; i++) {
	//	printf("%d ", ds.dlist[i]);
	//}
	//printf("\n");

	//for (int i = 0; i < 13; i++) {
	//	printf("%d ", ds.hlist[i]);
	//}
	//printf("\n");

	//for (int i = 0; i < 13; i++) {
	//	printf("%d ", ds.slist[i]);
	//}
	//printf("\n");


	 //1 = miss , 2 = duplicate 
	if (duplicateAndMissCard(ds.clist) == 1 || duplicateAndMissCard(ds.dlist) == 1 || duplicateAndMissCard(ds.hlist) == 1 || duplicateAndMissCard(ds.slist) == 1) {
		printMissingcard(ds.clist, ds.dlist, ds.hlist, ds.slist);
		exit(0);
	}
	else if (duplicateAndMissCard(ds.clist) == 2 || duplicateAndMissCard(ds.dlist) == 2 || duplicateAndMissCard(ds.hlist) == 2 || duplicateAndMissCard(ds.slist) == 2) {
		printDuplicateCard(ds.clist, ds.dlist, ds.hlist, ds.slist);
		exit(0);
	}

	//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD&&&&&&&&&&&&&&&&&&&&&&&&MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
	printf("%d covered cards\n", countCoverdList);
	printf("%d stock cards\n", countStockList);
	printf("%d wast cards\n", countWasteList);

	//how to found the card error!
	//when you have miss or duplicate card there is format error in card shape or card number
	//if you found the missing or duplicate card then
	//we can track back to where the card is and then express error and the line.

	SettingTableCheck();
	//int totalCheck;
	//totalCheck = checkTheTable(firstLine, FirstSize) + checkTheTable(secondLine, SecondSize) + checkTheTable(thridLine, ThreeSize) + checkTheTable(fourLine, FourSize)
	//	+ checkTheTable(fiveLine, FiveSize) + checkTheTable(sixLine, SixSize) + checkTheTable(sevenLine, SevenSize);
	//if (totalCheck != 7)
	//{
	//	printf("Tableau piles are invalid!\n");
	//}



	return 0;
}

void openFile()
{
	scanf("%s", &filename);

	fp = fopen(filename, "r");
	if (fp == NULL)
	{
		fp = fopen("Test1.txt", "r");
		if (fp == NULL)
		{
			exit(1); //there is error
		}
	}
}

void convertToLineData()
{
	while (!feof(fp))
	{
		fgets(data[0], 100, fp);
		if (data[0][0] == '#' || data[0][0] == '\n' || data[0][1] == '#')
		{

		}
		else
		{
			for (int j = 0; j < 100; j++)
			{
				if (data[0][j] == '?')
				{
					break;
				}
				else
				{
					linedata[size][j] = data[0][j];
				}
			}
			//printf("%s\n", linedata[size]);
			size++;
		}
	}

}

void makeBoolean(int i)
{
	int j = 0;
	int check = 0;
	int k = 0;
	for (int t = 0; t < 3; t++)
	{
		if (linedata[i][t] == ' ')
		{
			k = t;
			check = 1;
		}
	}

	for (j; j < 7; j++)	//rules
	{
		if (check == 1)
		{
			if (RString[j - k] != linedata[i][j])
				break;
		}
		else
		{
			if (RString[j] != linedata[i][j])
				break;
		}
		if (j == 5)
		{
			Frule = 1;
			Ffound = 0;
			Ftable = 0;
			Fstock = 0;
			Fmoves = 0;
			JChange = 1;
		}
	}
	for (j; j < 12; j++) //foundations
	{
		if (check == 1)
		{
			if (FString[j - k] != linedata[i][j])
				break;
		}
		else
		{
			if (FString[j] != linedata[i][j])
				break;
		}
		if (j == 11)
		{
			Frule = 0;
			Ffound = 1;
			Ftable = 0;
			Fstock = 0;
			Fmoves = 0;
			JChange = 1;
		}
	}
	for (j; j < 8; j++)	//tableau
	{
		if (check == 1)
		{
			if (TString[j - k] != linedata[i][j])
				break;
		}
		else
		{
			if (TString[j] != linedata[i][j])
				break;
		}
		if (j == 7)
		{
			Frule = 0;
			Ffound = 0;
			Ftable = 1;
			Fstock = 0;
			Fmoves = 0;
			JChange = 1;
		}
	}
	for (j; j < 6; j++)	//stock
	{
		if (check == 1)
		{
			if (SString[j - k] != linedata[i][j])
				break;
		}
		else
		{
			if (SString[j] != linedata[i][j])
				break;
		}
		if (j == 5)
		{
			Frule = 0;
			Ffound = 0;
			Ftable = 0;
			Fstock = 1;
			Fmoves = 0;
			JChange = 1;
		}
	}
	for (j; j < 6; j++)	//moves
	{
		if (check == 1)
		{
			if (MString[j - k] != linedata[i][j])
				break;
		}
		else
		{
			if (MString[j] != linedata[i][j])
				break;
		}
		if (j == 5)
		{
			Frule = 0;
			Ffound = 0;
			Ftable = 0;
			Fstock = 0;
			Fmoves = 1;
			JChange = 1;
		}
	}
}

void SeperateData(int i)
{
	if (Frule == 1)	//the line is rule data
	{
		int t = 0;
		int foundF = 0;
		for (int i = 0; i < 100; i++)
		{
			if (linedata[i][t] == ' ')
				t++;
		}
		while (linedata[i][t] != '\n')	//rules 
		{
			if (JChange == 1 && linedata[i][t] == 'F')
			{
				foundF = 1;
				t = t + 10;
			}
			if (foundF == 0)
			{
				int blank = 0;
				if (linedata[i][t] == ' ')
					blank++;
				for (int j = blank; j < 4 + blank; j++)	//find the turn
				{
					if (TurnString[j] != linedata[i][t + j])
						break;
					if (j == 3)
					{
						gameTurns = linedata[i][j + t + 2];
						if (linedata[i][j + t + 3] != ' ' && linedata[i][j + t + 3] != '\n')
						{
							char ch;
							printf("1Error near line %d : Invalid turn or limit\n", i);
							printf("please make sure there is space between limit or turn\n");
							printf("Exiting program beacuse of error press any key and hit enter\n");
							scanf("%c", &ch);
							exit(1);
						}
					}
				}
				for (int j = blank; j < 9 + blank; j++)		//find the unlimit
				{
					if (unlimit[j] != linedata[i][t + j])
						break;
					if (j == 8)
					{
						gameLimit = '0';
					}
				}
				for (int j = blank; j < 6 + blank; j++)		//find the limit num
				{
					if (lString[j] != linedata[i][t + j])
						break;
					if (j == 5)
					{
						gameLimit = linedata[i][j + t + 1];
						if (linedata[i][j + t + 2] != ' ' && linedata[i][j + t + 3] != '\n')
						{
							char ch;
							printf("3Error near line %d : Invalid turn or limit\n", i);
							printf("please make sure there is space between limit or turn\n");
							printf("Exiting program beacuse of error press any key and hit enter\n");
							scanf("%c", &ch);
							exit(1);
						}
					}
				}

			}
			else
			{
				for (int k = 0; k < 20; k++)
				{
					if (num[k] == linedata[i][t])
					{
						foundations[FoundationSize] = num[k];
						FoundationSize++;
					}

				}
			}
			if (JChange != 1 || (JChange == 1 && foundF == 1))
			{
				if (gameTurns != '1' && gameTurns != '3' && gameLimit != '0' && gameLimit != '1' && gameLimit != '2' && gameLimit != '3' && gameLimit != '4'
					&& gameLimit != '5' && gameLimit != '6' && gameLimit != '7' && gameLimit != '8' && gameLimit != '9')
				{
					char ch;
					printf("Error near line %d : Invalid turn or limit\n", i);
					printf("Exiting program beacuse of error press any key and hit enter\n");
					scanf("%c", &ch);
					exit(1);
				}
			}
			t++;
		}
		foundF = 0;
	}
	if (JChange != 1 && (gameTurns == '$' && gameLimit == '$'))
	{
		char ch;
		printf("Error near line %d : Expected 'RULES:'\n", i);
		printf("Exiting program beacuse of error press any key and hit enter\n");
		scanf("%c", &ch);
		exit(1);
	}
	if (Ffound == 1)
	{
		int j;
		if (JChange == 1)
			j = 11;
		else
			j = 0;
		while (linedata[i][j] != '\n')
		{
			if (linedata[i][j] == '#')
				break;
			for (int k = 0; k < 20; k++)
			{
				if (num[k] == linedata[i][j])
				{
					foundations[FoundationSize] = num[k];
					FoundationSize++;
				}

			}
			j++;
		}
	}
	if (Ffound == 0 && Frule == 0 && Ftable == 0 && Fstock == 0 && FMove == 0 && FoundationSize == 0)
	{
		char ch;
		printf("Error near line %d : Expected 'FOUNDATIONS:'\n", i);
		printf("Exiting program beacuse of error press any key and hit enter\n");
		scanf("%c", &ch);
		exit(1);
	}
	if (Ftable == 1)
	{
		int j;
		if (JChange == 1)
			j = 7;
		else
			j = 0;
		while (linedata[i][j] != '\n')
		{
			if (linedata[i][j] == '#')
				break;
			for (int k = 0; k < 20; k++)
			{
				if (num[k] == linedata[i][j])
				{
					tableau[tabluSize] = num[k];
					tabluSize++;
				}
			}
			j++;
		}
		tableau[tabluSize] = '@';
		tabluSize++;
	}

	if (Ffound == 0 && Frule == 0 && Ftable == 0 && Fstock == 0 && FMove == 0 && tabluSize == 0)
	{
		char ch;
		printf("Error near line %d : Expected 'TABLEAU:'\n", i);
		printf("Exiting program beacuse of error press any key and hit enter\n");
		scanf("%c", &ch);
		exit(1);
	}
	if (Ffound == 0 && Frule == 0 && Ftable == 0 && Fstock == 1 && FMove == 0)
	{
		int lineSize = 0;
		for (int q = 0; q < tabluSize; q++)
		{
			if (tableau[q] == '@')
				lineSize++;
			if (q == tabluSize - 1 && lineSize != 8)
			{
				char ch;
				printf("Error near line %d : check if TABLEAU have 7 lines'\n", i);
				printf("Exiting program beacuse of error press any key and hit enter\n");
				scanf("%c", &ch);
				exit(1);
			}
		}
	}

	if (Fstock == 1)
	{
		int j;
		if (JChange == 1)
			j = 5;
		else
			j = 0;
		while (linedata[i][j] != '\n')
		{
			if (linedata[i][j] == '#')
				break;
			if (Fmoves == 1)
				break;
			for (int k = 0; k < 20; k++)
			{
				if (num[k] == linedata[i][j])
				{
					stock[stockSize] = num[k];
					stockSize++;
				}
			}
			if (JChange == 1 && linedata[i][j] == 'M')
				Fmoves = 1;
			j++;
		}
	}
	if (Ffound == 0 && Frule == 0 && Ftable == 0 && Fstock == 0 && FMove == 0 && stockSize == 0)
	{
		char ch;
		printf("Error near line %d : Expected 'STOCK:'\n", i);
		printf("Exiting program beacuse of error press any key and hit enter\n");
		scanf("%c", &ch);
		exit(1);
	}
	JChange = 0;
	if (Fmoves == 1)
	{
		int j = 0;
		while (linedata[i][j] != '\n')
		{
			if (linedata[i][j] == '#')
				break;
			if (linedata[i][j] == ' ')
			{

			}
			else
			{
				if (linedata[i][j] == '-')
				{
					moves[moveSize] = linedata[i][j - 1];
					moveSize++;
					moves[moveSize] = linedata[i][j];
					moveSize++;
					moves[moveSize] = linedata[i][j + 2];
					moveSize++;
				}
			}
			j++;
		}
	}
	if (i == size - 1 && Fmoves == 0)
	{
		char ch;
		printf("Error near line %d : Expected 'MOVES:'\n", i);
		printf("Exiting program beacuse of error press any key and hit enter\n");
		scanf("%c", &ch);
		exit(1);
	}
}

//@@@@@@@@@@@@@@@@@@@@@@@@WARNING@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
int checkTheTable(char var[], int size)	//if check is 1 it mean okay, if 0 something is wrong
{
	int check = 0;
	if ((size == 0) && (var[0] = '|'))
		check++;
	int index = 0;
	for (int i = 0; i < size; i++)
	{
		if (var[i] == '|')
			index = i;
	}
	if (size < 5)
	{
		check++;
	}
	else
	{
		for (index; index < size - 3; index++)
		{

			if (index % 2 == 0)	//even									//when replacing the int to the data but origin data is still safe.
			{

				if (var[index] > var[index + 2])
				{

				}
				else
				{
					break;
				}
			}
			else   //odd
			{
				if (var[index] == 'h' || var[index] == 'd')
				{
					if (var[index + 2] == 's' || var[index + 2] == 'c')
					{

					}
					else
					{
						break;
					}
				}
				else
				{
					if (var[index + 2] == 'h' || var[index + 2] == 'd')
					{

					}
					else
					{
						break;
					}
				}
			}
			if (index == size - 4)
				check++;
		}
	}
	return check;
}

void SettingTableCheck()
{
	int i = 1;
	line = 1;
	while (tableau[i] != '!')
	{
		if (line == 1)
		{
			firstLine[FirstSize] = tableau[i];
			FirstSize++;
		}
		if (line == 2)
		{
			secondLine[SecondSize] = tableau[i];
			SecondSize++;
		}
		if (line == 3)
		{
			thridLine[ThreeSize] = tableau[i];
			ThreeSize++;
		}
		if (line == 4)
		{
			fourLine[FourSize] = tableau[i];
			FourSize++;
		}
		if (line == 5)
		{
			fiveLine[FiveSize] = tableau[i];
			FiveSize++;
		}
		if (line == 6)
		{
			sixLine[SixSize] = tableau[i];
			SixSize++;
		}
		if (line == 7)
		{
			sevenLine[SevenSize] = tableau[i];
			SevenSize++;
		}
		if (tableau[i] == '@')
		{
			line++;
		}
		i++;
	}
}

//================================DW================================================================================================================================

int helpMethod(char ch)
{

	int temp = 0;

	if (ch == 'A') {
		temp = 1;
	}
	else if (ch == '2') {
		temp = 2;
	}
	else if (ch == '3') {
		temp = 3;
	}
	else if (ch == '4') {
		temp = 4;
	}
	else if (ch == '5') {
		temp = 5;
	}
	else if (ch == '6') {
		temp = 6;
	}
	else if (ch == '7') {
		temp = 7;
	}
	else if (ch == '8') {
		temp = 8;
	}
	else if (ch == '9') {
		temp = 9;
	}
	else if (ch == 'T') {
		temp = 10;
	}
	else if (ch == 'J') {
		temp = 11;
	}
	else if (ch == 'Q') {
		temp = 12;
	}
	else if (ch == 'K') {
		temp = 13;
	}
	return temp;
}

char* foundationsArr(char line[])
{

	int temp = 0;

	for (int i = 0; i < 100; i++) {
		if (line[i] == '!') {
			temp = i;
			break;
		}
	}

	for (int i = 0; i < temp; i++)
	{
		if (line[i] == 'c') {
			foundArr[0] = line[i - 1];
		}
		if (line[i] == 'd') {
			foundArr[1] = line[i - 1];
		}
		if (line[i] == 'h') {
			foundArr[2] = line[i - 1];
		}
		if (line[i] == 's') {
			foundArr[3] = line[i - 1];
		}
	}

	return foundArr;
}


char* tableauCount(char line[]) {

	int temp = 0;

	for (int i = 0; i < 100; i++) {
		if (line[i] == '!') {
			temp = i;
			break;
		}
	}

	int coverCount = 0;
	int openCount = 0;

	int index[14];
	int num = 0;
	for (int i = 1; i < temp; i++) {
		if (line[i] == '|') {
			index[num] = i;
			num++;
		}
		else if (line[i] == '@') {
			index[num] = i;
			num++;
		}
	}



	int std = 0;

	while (std <= temp) {
		if (std < index[0]) {
			if (line[std] == 'c' || line[std] == 'd' || line[std] == 'h' || line[std] == 's') {
				coverCount++;
			}
		}
		else if (index[1] < std && std < index[2]) {
			if (line[std] == 'c' || line[std] == 'd' || line[std] == 'h' || line[std] == 's') {
				coverCount++;
			}
		}
		else if (index[3] < std && std < index[4]) {
			if (line[std] == 'c' || line[std] == 'd' || line[std] == 'h' || line[std] == 's') {
				coverCount++;
			}
		}
		else if (index[5] < std && std < index[6]) {
			if (line[std] == 'c' || line[std] == 'd' || line[std] == 'h' || line[std] == 's') {
				coverCount++;
			}
		}
		else if (index[7] < std && std < index[8]) {
			if (line[std] == 'c' || line[std] == 'd' || line[std] == 'h' || line[std] == 's') {
				coverCount++;
			}
		}
		else if (index[9] < std && std < index[10]) {
			if (line[std] == 'c' || line[std] == 'd' || line[std] == 'h' || line[std] == 's') {
				coverCount++;
			}
		}
		else if (index[11] < std && std < index[12]) {
			if (line[std] == 'c' || line[std] == 'd' || line[std] == 'h' || line[std] == 's') {
				coverCount++;
			}
		}
		else {
			if (line[std] == 'c' || line[std] == 'd' || line[std] == 'h' || line[std] == 's') {
				openCount++;
			}
		}

		std++;
	}

	tableArr[0] = coverCount;
	tableArr[1] = openCount;

	return tableArr;
}

char* stockCount(char line[]) {

	int temp1 = 0;

	for (int i = 0; i < 100; i++) {
		if (line[i] == '|') {
			temp1 = i;
			break;
		}
	}

	int temp2 = 0;

	for (int i = 0; i < 100; i++) {
		if (line[i] == '!') {
			temp2 = i;
		}
	}

	int wasteCount = 0;
	int stockCount = 0;

	for (int i = 0; i < temp1; i++) {
		if (line[i] == 'c') {
			wasteCount++;
		}
		if (line[i] == 'd') {
			wasteCount++;
		}
		if (line[i] == 'h') {
			wasteCount++;
		}
		if (line[i] == 's') {
			wasteCount++;
		}
	}

	for (int i = temp1; i < temp2; i++) {
		if (line[i] == 'c') {
			stockCount++;
		}
		if (line[i] == 'd') {
			stockCount++;
		}
		if (line[i] == 'h') {
			stockCount++;
		}
		if (line[i] == 's') {
			stockCount++;
		}
	}

	//char tempArr[2];

	stockArr[0] = stockCount;
	stockArr[1] = wasteCount;

	return stockArr;
}

int duplicateAndMissCard(int num[]) {

	int std = 0;

	for (int i = 0; i < 13; i++) {
		if (num[i] == 0) {
			std = 1;
		}
		else if (num[i] == 2) {
			std = 2;
		}
	}

	return std;
}

void printMissingcard(int clist[], int dlist[], int hlist[], int slist[]) {
	printf("Missing cards: ");
	for (int i = 0; i < 13; i++) {
		if (slist[i] == 0) {
			if (i == 0) {
				printf("As ");
			}
			else if (i == 9) {
				printf("Ts ");
			}
			else if (i == 10) {
				printf("Js ");
			}
			else if (i == 11) {
				printf("Qs ");
			}
			else if (i == 12) {
				printf("Ks ");
			}
			else {
				printf("%ds ", i);
			}
		}
	}

	for (int i = 0; i < 13; i++) {
		if (hlist[i] == 0) {
			if (i == 0) {
				printf("Ah ");
			}
			else if (i == 9) {
				printf("Th ");
			}
			else if (i == 10) {
				printf("Jh ");
			}
			else if (i == 11) {
				printf("Qh ");
			}
			else if (i == 12) {
				printf("Kh ");
			}
			else {
				printf("%dh ", i);
			}
		}
	}

	for (int i = 0; i < 13; i++) {
		if (dlist[i] == 0) {
			if (i == 0) {
				printf("Ad ");
			}
			else if (i == 9) {
				printf("Td ");
			}
			else if (i == 10) {
				printf("Jd ");
			}
			else if (i == 11) {
				printf("Qd ");
			}
			else if (i == 12) {
				printf("Kd ");
			}
			else {
				printf("%dd ", i);
			}
		}
	}

	for (int i = 0; i < 13; i++) {
		if (clist[i] == 0) {
			if (i == 0) {
				printf("Ac ");
			}
			else if (i == 9) {
				printf("Tc ");
			}
			else if (i == 10) {
				printf("Jc ");
			}
			else if (i == 11) {
				printf("Qc ");
			}
			else if (i == 12) {
				printf("Kc ");
			}
			else {
				printf("%dc ", i);
			}
		}
	}
	//printf("\n");
}

void printDuplicateCard(int clist[], int dlist[], int hlist[], int slist[]) {
	printf("Duplicated cards: ");
	for (int i = 0; i < 13; i++) {
		if (slist[i] >= 2) {
			if (i == 0) {
				printf("As ");
			}
			else if (i == 9) {
				printf("Ts ");
			}
			else if (i == 10) {
				printf("Js ");
			}
			else if (i == 11) {
				printf("Qs ");
			}
			else if (i == 12) {
				printf("Ks ");
			}
			else {
				printf("%ds ", i);
			}
		}
	}
	for (int i = 0; i < 13; i++) {
		if (hlist[i] >= 2) {
			if (i == 0) {
				printf("Ah ");
			}
			else if (i == 9) {
				printf("Th ");
			}
			else if (i == 10) {
				printf("Jh ");
			}
			else if (i == 11) {
				printf("Qh ");
			}
			else if (i == 12) {
				printf("Kh ");
			}
			else {
				printf("%dh ", i);
			}
		}
	}
	for (int i = 0; i < 13; i++) {
		if (dlist[i] >= 2) {
			if (i == 0) {
				printf("Ad ");
			}
			else if (i == 9) {
				printf("Td ");
			}
			else if (i == 10) {
				printf("Jd ");
			}
			else if (i == 11) {
				printf("Qd ");
			}
			else if (i == 12) {
				printf("Kd ");
			}
			else {
				printf("%dd ", i);
			}
		}
	}
	for (int i = 0; i < 13; i++) {
		if (clist[i] >= 2) {
			if (i == 0) {
				printf("Ac ");
			}
			else if (i == 9) {
				printf("Tc ");
			}
			else if (i == 10) {
				printf("Jc ");
			}
			else if (i == 11) {
				printf("Qc ");
			}
			else if (i == 12) {
				printf("Kc ");
			}
			else {
				printf("%dc ", i);
			}
		}
	}
	//printf("\n");
}





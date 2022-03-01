#pragma once
void openFile();

void convertToLineData();

void makeBoolean(int i);

void SeperateData(int i);

int checkTheTable(char var[], int size);

void SettingTableCheck();

int helpMethod(char ch);

char* foundationsArr(char line[]);

char* tableauCount(char line[]);

char* stockCount(char line[]);
void Eliminate(char* str, char ch,int start);
char getTurns();
char getLimit();
int getStockSize();

int duplicateAndMissCard(int num[]);

void printMissingcard(int clist[], int dlist[], int hlist[], int slist[]);

void printDuplicateCard(int clist[], int dlist[], int hlist[], int slist[]);

int mainRead();

void getData(char** data);

void getDataSize(int* dataSize);

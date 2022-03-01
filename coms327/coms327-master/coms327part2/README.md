This repository was created by Dongwoo Kang and Jihoo Kim, for COM S 327 Spring 2020 Project part2

Jihoo part============================================================

int moveTableau(char** dataTotal,char a, char b, int* dataSize)
-find the card from the tableau and move it. Delete the card from the data when the card is moving. Can move multiple card

int getInteger(char num)
-get the integer using char num

int findIndex(char a)
-find the index using char a

int checkCard(char** dataTotal, char a, int* dataSize)
-check the card if it can move with the higher card in tableau

int saveTableau(char** dataTotal,int* dataSize,char a,char num,char shape, int check)
- save the card to tableau when it moved to tableau

int saveFoundation(char** dataTotal,int* dataSize,char num,char shape)
- save the card to foundation when it moved to foundation

void showData(char** data,int* dataSize)
- show the data which is part for human readable

Dongwoo Kang part==========================================================

int WasteToFoundationOrTableau(char c1, char c2, char** data)
- return the error message if there are errors 
- and modify the data in waste and foundation when a card is moved from was to foundation
- or modify the data in waste and Tableau when a card is moved from was to tableau

int StockToWaste(char c, char c2, char** data)
-  return the error message if there are
-  and modify the data in stock and waste part when user turn out a card from stock. 
-  it depends on turn value (1 or 3) and it can reverse the waste card when it get 'r'

void printTableau(char** data, int* dataSize)
-  return the data of Tableau as human readiable formmationg.

char getTurns() 
- return the turn value of this game

char getLimit() 
- return a number of limit of this game

int getStockSize() 
- return a size of stock.

Together =============================

main method

-implements those above methods to show right output information.

int callRead()

-calling the part1 part

void executeMove(char** dataTotal, int* dataSize)

-execute the move function

import java.util.ArrayList;
import java.util.List;

import static java.lang.Math.abs;

public class Game {
    public int currentPlayer;   //1 : 1st player, 2 : 2nd player
    public int[][] board;      //0 empty, 1 1st player chip, 2 2nd player chip, 3 1st player king, 4 2nd player king
    public int firstScore;
    public int secondScore;
    public boolean finish;
    public Game(){

    }

    public Game(Game game){
        this.board = new int[game.board.length][game.board[0].length];
        for(int i=0;i<game.board.length;i++){
            for(int j=0;j<game.board[0].length;j++){
                board[i][j] = game.board[i][j];
            }
        }
        this.currentPlayer = game.currentPlayer;
        finish = false;
    }

    void setCurrentPlayer(int player){
        currentPlayer = player;
    }

    boolean isFinish(){
        if(currentPlayer == 1 && firstScore == 12)
            return true;
        if(currentPlayer == 2 && secondScore == 12)
            return true;
        return false;
    }
    void newGame(){
        //initialize into empty space
        board = new int[8][8];
        for(int i=0;i<8;i++){
            for(int j=0;j<8;j++){
                board[i][j] = 0;
            }
        }
        //place first player chip
        for(int j=0;j<3;j++){
             if(j%2==0){
                 for(int i=1;i<8;i=i+2){
                     board[i][j] = 1;
                 }
             }
             else{
                 for(int i=0;i<8;i=i+2){
                     board[i][j] = 1;
                 }
             }
        }
        //place second player chip
        for(int j=5;j<8;j++){
            if(j%2==0){
                for(int i=1;i<8;i=i+2){
                    board[i][j] = 2;
                }
            }
            else{
                for(int i=0;i<8;i=i+2){
                    board[i][j] = 2;
                }
            }
        }
        finish = false;
    }

    void printBoard(){
        System.out.println("   0 1 2 3 4 5 6 7");
        System.out.println("-------------------");
        for(int j=0;j<this.board.length;j++){
            System.out.print(j + "| ");
            for(int i=0;i<this.board[0].length;i++){
                if(board[i][j]==0)
                    System.out.print(". ");
                else
                    System.out.print(board[i][j] + " ");
            }
            System.out.println();
        }
    }

    //get all the possible move
    List<Move> move(Game game){
        List<Move> slide = new ArrayList<Move>();
        List<Move> jump = new ArrayList<Move>();
        int[][] board = game.board;
        if(currentPlayer == 1){
            for(int i=0;i<8;i++){
                for(int j=0;j<8;j++){
                    if(board[i][j]==1){
                        //check slide is available
                        if((i+1<8)&&(j+1<8)&&board[i+1][j+1]==0){
                            Move move = new Move(i,j,i+1,j+1,board);
                            slide.add(move);
                        }
                        if((i-1>=0)&&(j+1<8)&&board[i-1][j+1]==0){
                            Move move = new Move(i,j,i-1,j+1,board);
                            slide.add(move);
                        }
                        //check jump is available
                        if((i+2<8)&&(j+2<8)&&(board[i+1][j+1]==2||board[i+1][j+1]==4)&&board[i+2][j+2]==0){
                            Move move = new Move(i,j,i+2,j+2,board);
                            move.captureRow.add(i+1);
                            move.captureCol.add(j+1);
                            jump.add(move);
                        }
                        if((i-2>=0)&&(j+2<8)&&(board[i-1][j+1]==2||board[i-1][j+1]==4)&&board[i-2][j+2]==0){
                            Move move = new Move(i,j,i-2,j+2,board);
                            move.captureRow.add(i-1);
                            move.captureCol.add(j+1);
                            jump.add(move);
                        }
                    }
                    //king
                    if(board[i][j]==3){
                        //check slide is available
                        if((i+1<8)&&(j+1<8)&&board[i+1][j+1]==0){
                            Move move = new Move(i,j,i+1,j+1,board);
                            slide.add(move);
                        }
                        if((i+1<8)&&(j-1>0)&&board[i+1][j-1]==0){
                            Move move = new Move(i,j,i+1,j-1,board);
                            slide.add(move);
                        }
                        if((i-1>0)&&(j+1<8)&&board[i-1][j+1]==0){
                            Move move = new Move(i,j,i-1,j+1,board);
                            slide.add(move);
                        }
                        if((i-1>0)&&(j-1>0)&&board[i-1][j-1]==0){
                            Move move = new Move(i,j,i-1,j-1,board);
                            slide.add(move);
                        }
                        //check jump is available
                        int count = 0;
                        ArrayList<Integer> CR = new ArrayList();
                        ArrayList<Integer> CC = new ArrayList();
                        getJump(board,count,jump,1,i,j,i,j,i,j,CR,CC);

                    }
                }
            }
        }
        else{
            for(int i=0;i<8;i++){
                for(int j=0;j<8;j++){
                    if(board[i][j]==2){
                        //check slide is available
                        if((i+1<8)&&(j-1>=0)&&board[i+1][j-1]==0){
                            Move move = new Move(i,j,i+1,j-1,board);
                            slide.add(move);
                        }
                        if((i-1>=0)&&(j-1>=0)&&board[i-1][j-1]==0){
                            Move move = new Move(i,j,i-1,j-1,board);
                            slide.add(move);
                        }
                        //check jump is available
                        if((i-2>=0)&&(j-2>=0)&&(board[i-1][j-1]==1||board[i-1][j-1]==3)&&board[i-2][j-2]==0){
                            Move move = new Move(i,j,i-2,j-2,board);
                            move.captureRow.add(i-1);
                            move.captureCol.add(j-1);
                            jump.add(move);
                        }
                        if((i+2<8)&&(j-2>=0)&&(board[i+1][j-1]==1||board[i+1][j-1]==3)&&board[i+2][j-2]==0){
                            Move move = new Move(i,j,i+2,j-2,board);
                            move.captureRow.add(i+1);
                            move.captureCol.add(j-1);
                            jump.add(move);
                        }
                    }
                    //king
                    if(board[i][j]==4){
                        //check slide is available
                        if((i+1<8)&&(j+1<8)&&board[i+1][j+1]==0){
                            Move move = new Move(i,j,i+1,j+1,board);
                            slide.add(move);
                        }
                        if((i+1<8)&&(j-1>=0)&&board[i+1][j-1]==0){
                            Move move = new Move(i,j,i+1,j-1,board);
                            slide.add(move);
                        }
                        if((i-1>=0)&&(j+1<8)&&board[i-1][j+1]==0){
                            Move move = new Move(i,j,i-1,j+1,board);
                            slide.add(move);
                        }
                        if((i-1>=0)&&(j-1>=0)&&board[i-1][j-1]==0){
                            Move move = new Move(i,j,i-1,j-1,board);
                            slide.add(move);
                        }
                        //check jump is available
                        int count = 0;
                        ArrayList<Integer> CR = new ArrayList();
                        ArrayList<Integer> CC = new ArrayList();
                        getJump(board,count,jump,2,i,j,i,j,i,j,CR,CC);

                    }
                }
            }
        }
        if(jump.size()==0){
            return slide;
        }
        else{
            return jump;
        }
    }

    void getJump(int[][] board,int count,List<Move> jump,int player,int row,int col,int prevRow,int prevCol
            ,int initialRow,int initialCol, ArrayList<Integer> captureRow,ArrayList<Integer> captureCol){
        if(player==1){
            if(count!=0){
                if(checkPossibleJump(board,player,row,col)==1){
                    Move move = new Move(initialRow,initialCol,row,col,board);
                    move.captureRow = captureRow;
                    move.captureCol = captureCol;
                    jump.add(move);
                }
                else{
                    if((row+2<8)&&(col+2<8)&&(board[row+1][col+1]==2||board[row+1][col+1]==4)&&board[row+2][col+2]==0){
                        if(row+2 == prevRow && col+2==prevCol){
                            //already visited so do nothing
                        }
                        else{
                            captureRow.add(row+1);
                            captureCol.add(col+1);
                            getJump(board,count++,jump,player,row+2,col+2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                    if((row-2>=0)&&(col+2<8)&&(board[row-1][col+1]==2||board[row-1][col+1]==4)&&board[row-2][col+2]==0){
                        if(row-2 == prevRow && col+2==prevCol){
                            //already visited so do nothing
                        }
                        else{
                            captureRow.add(row-1);
                            captureCol.add(col+1);
                            getJump(board,count++,jump,player,row-2,col+2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                    if((row+2<8)&&(col-2>=0)&&(board[row+1][col-1]==2||board[row+1][col-1]==4)&&board[row+2][col-2]==0){
                        if(row+2 == prevRow && col-2==prevCol){
                            //already visited so do nothing
                        }
                        else{
                            captureRow.add(row+1);
                            captureCol.add(col-1);
                            getJump(board,count++,jump,player,row+2,col-2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                    if((row-2>=0)&&(col-2>=0)&&(board[row-1][col-1]==2||board[row-1][col-1]==4)&&board[row-2][col-2]==0){
                        if(row-2 == prevRow && col-2==prevCol){
                            //already visited so do nothing
                        }
                        else{
                            captureRow.add(row-1);
                            captureCol.add(col-1);
                            getJump(board,count++,jump,player,row-2,col-2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                }
            }
            else{
                if((row+2<8)&&(col+2<8)&&(board[row+1][col+1]==2||board[row+1][col+1]==4)&&board[row+2][col+2]==0){
                    captureRow.add(row+1);
                    captureCol.add(col+1);
                    getJump(board,count++,jump,player,row+2,col+2,row,col,
                            initialRow,initialCol,captureRow,captureCol);
                }
                if((row-2>=0)&&(col+2<8)&&(board[row-1][col+1]==2||board[row-1][col+1]==4)&&board[row-2][col+2]==0){
                    captureRow.add(row-1);
                    captureCol.add(col+1);
                    getJump(board,count++,jump,player,row-2,col+2,row,col,
                            initialRow,initialCol,captureRow,captureCol);
                }
                if((row+2<8)&&(col-2>=0)&&(board[row+1][col-1]==2||board[row+1][col-1]==4)&&board[row+2][col-2]==0){
                    captureRow.add(row+1);
                    captureCol.add(col-1);
                    getJump(board,count++,jump,player,row+2,col-2,row,col,
                            initialRow,initialCol,captureRow,captureCol);
                }
                if((row-2>=0)&&(col-2>=0)&&(board[row-1][col-1]==2||board[row-1][col-1]==4)&&board[row-2][col-2]==0){
                    captureRow.add(row-1);
                    captureCol.add(col-1);
                    getJump(board,count++,jump,player,row-2,col-2,row,col,
                            initialRow,initialCol,captureRow,captureCol);
                }
            }
        }
        else{
            if(count!=0){
                if(checkPossibleJump(board,player,row,col)==1){
                    Move move = new Move(initialRow,initialCol,row,col,board);
                    move.captureRow = captureRow;
                    move.captureCol = captureCol;
                    jump.add(move);
                }
                else{
                    if((row+2<8)&&(col+2<8)&&(board[row+1][col+1]==1||board[row+1][col+1]==3)&&board[row+2][col+2]==0){
                        if(row+2 == prevRow && col+2==prevCol){
                            //already visited so do nothing
                        }
                        else{
                            captureRow.add(row+1);
                            captureCol.add(col+1);
                            getJump(board,count++,jump,player,row+2,col+2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                    if((row-2>=0)&&(col+2<8)&&(board[row-1][col+1]==1||board[row-1][col+1]==3)&&board[row-2][col+2]==0){
                        if(row-2 == prevRow && col+2==prevCol){
                            //already visited so do nothing
                        }
                        else{
                            captureRow.add(row-1);
                            captureCol.add(col+1);
                            getJump(board,count++,jump,player,row-2,col+2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                    if((row+2<8)&&(col-2>=0)&&(board[row+1][col-1]==1||board[row+1][col-1]==3)&&board[row+2][col-2]==0){
                        if(row+2 == prevRow && col-2==prevCol){
                            //already visited so do nothing
                        }
                        else{
                            captureRow.add(row+1);
                            captureCol.add(col-1);
                            getJump(board,count++,jump,player,row+2,col-2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                    if((row-2>=0)&&(col-2>=0)&&(board[row-1][col-1]==1||board[row-1][col-1]==3)&&board[row-2][col-2]==0){
                        if(row-2 == prevRow && col-2==prevCol){
                            //already visited so do nothing
                        }
                        else{
                            captureRow.add(row-1);
                            captureCol.add(col-1);
                            getJump(board,count++,jump,player,row-2,col-2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                }
            }
            else{

                    if((row+2<8)&&(col+2<8)&&(board[row+1][col+1]==1||board[row+1][col+1]==3)&&board[row+2][col+2]==0){
                        if(row+2==prevRow && col+2==prevCol){
                            //do nothing
                        }
                        else{
                            captureRow.add(row+1);
                            captureCol.add(col+1);
                            getJump(board,count++,jump,player,row+2,col+2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                    if((row-2>=0)&&(col+2<8)&&(board[row-1][col+1]==1||board[row-1][col+1]==3)&&board[row-2][col+2]==0){
                        if(row-2 == prevRow && col+2 == prevCol){

                        }
                        else{
                            captureRow.add(row-1);
                            captureCol.add(col+1);
                            getJump(board,count++,jump,player,row-2,col+2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                    if((row+2<8)&&(col-2>=0)&&(board[row+1][col-1]==1||board[row+1][col-1]==3)&&board[row+2][col-2]==0){
                        if(row+2==prevRow && col-2 == prevCol){

                        }
                        else{
                            captureRow.add(row+1);
                            captureCol.add(col-1);
                            getJump(board,count++,jump,player,row+2,col-2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }
                    if((row-2>=0)&&(col-2>=0)&&(board[row-1][col-1]==1||board[row-1][col-1]==3)&&board[row-2][col-2]==0){
                        if(row-2==prevRow&&col-2==prevCol){

                        }
                        else{
                            captureRow.add(row-1);
                            captureCol.add(col-1);
                            getJump(board,count++,jump,player,row-2,col-2,row,col,
                                    initialRow,initialCol,captureRow,captureCol);
                        }
                    }

            }
        }
    }

    int checkPossibleJump(int[][] board,int player,int row,int col){
        int result=0;
        if(player == 1){
            if((row+2<8)&&(col+2<8)&&(board[row+1][col+1]==2||board[row+1][col+1]==4)&&board[row+2][col+2]==0){
                result++;
            }
            if((row-2>=0)&&(col+2<8)&&(board[row-1][col+1]==2||board[row-1][col+1]==4)&&board[row-2][col+2]==0){
                result++;
            }
            if((row+2<8)&&(col-2>=0)&&(board[row+1][col-1]==2||board[row+1][col-1]==4)&&board[row+2][col-2]==0){
                result++;
            }
            if((row-2>=0)&&(col-2>=0)&&(board[row-1][col-1]==2||board[row-1][col-1]==4)&&board[row-2][col-2]==0){
                result++;
            }
        }
        else{
            if((row+2<8)&&(col+2<8)&&(board[row+1][col+1]==1||board[row+1][col+1]==3)&&board[row+2][col+2]==0){
                result++;
            }
            if((row-2>=0)&&(col+2<8)&&(board[row-1][col+1]==1||board[row-1][col+1]==3)&&board[row-2][col+2]==0){
                result++;
            }
            if((row+2<8)&&(col-2>=0)&&(board[row+1][col-1]==1||board[row+1][col-1]==3)&&board[row+2][col-2]==0){
                result++;
            }
            if((row-2>=0)&&(col-2>=0)&&(board[row-1][col-1]==1||board[row-1][col-1]==3)&&board[row-2][col-2]==0){
                result++;
            }
        }
        return result;
    }

    void moved(Move move,int[][] state){
        //update the score
        if(state[move.startRow][move.startCol]==1){
            for(int i=0;i<move.captureRow.size();i++) {
                firstScore++;
            }
        }
        else if(state[move.startRow][move.startCol]==2){
            for(int i=0;i<move.captureRow.size();i++) {
                secondScore++;
            }
        }
        //remove all the captured
        for(int i=0;i<move.captureRow.size();i++) {
            state[move.captureRow.get(i)][move.captureCol.get(i)]=0;
        }
        //make first player king if it satisfy condition
        if(move.endCol==0&&state[move.startRow][move.startCol]==2){
            state[move.endRow][move.endCol] = 4;
            state[move.startRow][move.startCol] = 0;
        }
        //make second player king if it satisfy condition
        else if(move.endCol==7&&state[move.startRow][move.startCol]==1){
            state[move.endRow][move.endCol] = 3;
            state[move.startRow][move.startCol] = 0;
        }
        //change the move
        else{
            state[move.endRow][move.endCol] = state[move.startRow][move.startCol];
            state[move.startRow][move.startCol] = 0;
        }
        move.state = state;
    }
}


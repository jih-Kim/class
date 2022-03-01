import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Agent {
    public int computerPlayer;
    public int maxDepth;
    public int heuristicType;
    public int numPlayerChip;
    public int numPlayerKing;
    public int numComputerChip;
    public int numComputerKing;

    public Agent(int CP,int heuristic){
        this.computerPlayer = CP;
        this.heuristicType = heuristic;
    }

    Move alphaBeta(Game game, int maxDepth){
        List<Move> bestMoveDepth = new ArrayList<Move>();
        game.setCurrentPlayer(computerPlayer);
        List<Move> legalMove = game.move(game);
        Random rand = new Random();
        int depthReached;
        int bestVal;
        Move bestMove = null;
        if(legalMove.size()==1)
            return legalMove.get(0);
        for(int i=0;i<maxDepth;i++){
            int val = Integer.MIN_VALUE;
            for(int j=0;j<legalMove.size();j++){
                Game copy = new Game(game);
                copy.moved(legalMove.get(j),copy.board);
                int min = minVal(copy,Integer.MIN_VALUE,Integer.MAX_VALUE,0);
                if(min == val){
                    bestMoveDepth.add(legalMove.get(j));
                }
                if(min>val){
                    bestMoveDepth.clear();
                    bestMoveDepth.add(legalMove.get(j));
                    val = min;
                }
                if(val==Integer.MAX_VALUE)
                    break;
            }
            int chose = rand.nextInt(bestMoveDepth.size());
            bestMove = bestMoveDepth.get(chose);
            depthReached = i;
            bestVal = val;
            if(bestVal == Integer.MAX_VALUE)
                break;
        }
        return bestMove;
    }

    boolean checkDepth(int numMoves, int depth){
        if(numMoves==0 || depth==maxDepth)
            return true;
        return false;
    }

    int maxVal(Game game,int alpha, int beta, int depth){
        List<Move> ligalMove = game.move(game);
        if(checkDepth(ligalMove.size(),depth))
            return heuristic(game);
        int temp = Integer.MIN_VALUE;
        for(int i=0;i<ligalMove.size();i++){
            Game copy = new Game(game);
            copy.moved(ligalMove.get(i),copy.board);
            temp = Math.max(temp,minVal(copy,alpha,beta,depth+1));
            if(temp >= beta)
                return temp;
            alpha = Math.max(alpha,temp);
        }
        return temp;
    }

    int minVal(Game game,int alpha, int beta, int depth){
        List<Move> ligalMove = game.move(game);
        if(checkDepth(ligalMove.size(),depth))
            return heuristic(game);
        int temp = Integer.MAX_VALUE;
        for(int i=0;i<ligalMove.size();i++){
            Game copy = new Game(game);
            copy.moved(ligalMove.get(i),copy.board);
            temp = Math.min(temp,maxVal(copy,alpha,beta,depth+1));
            if(temp <= beta)
                return temp;
            alpha = Math.min(alpha,temp);
        }
        return temp;
    }

    int heuristic(Game game){
        if(heuristicType == 0){
            return firstCalculation(game);
        }
        if(heuristicType == 1){
            return secondCalculation(game);
        }
        return -1;
    }
    //calculate the value.
    int firstCalculation(Game game){
        int row = game.board.length;
        int col = game.board[0].length;
        int value = 0;
        for(int i=0;i<row;i++){
            for(int j=0;j<col;j++){
                if(computerPlayer==1){
                    if(game.board[i][j]==1){
                        value = value+3;
                    }
                    if(game.board[i][j]==2){
                        value = value-3;
                    }
                    if(game.board[i][j]==3){
                        value = value+5;
                    }
                    if(game.board[i][j]==4){
                        value = value-5;
                    }
                }
                else{
                    if(game.board[i][j]==1){
                        value = value-3;
                    }
                    if(game.board[i][j]==2){
                        value = value+3;
                    }
                    if(game.board[i][j]==3){
                        value = value-5;
                    }
                    if(game.board[i][j]==4){
                        value = value+5;
                    }
                }
            }
        }
        return value;
    }

    int secondCalculation(Game game){
        int row = game.board.length;
        int col = game.board[0].length;
        int value = 0;
        for(int i=0;i<row;i++) {
            for (int j = 0; j < col; j++) {
                if(computerPlayer==1){
                    if(game.board[i][j]==1){
                        value = (int)(value + 3 + (0.5*i) + numDefendNeighbor(i,j,game.board));
                        if(j==0 || j==7)
                            value = value+1;
                        if(i==0)
                            value = value+2;
                    }
                    if(game.board[i][j]==2){
                        value = (int)(value - 3 + ((7-i)*0.5)+numDefendNeighbor(i,j,game.board));
                        if(j==0 || j==7)
                            value = value-1;
                        if(i==7)
                            value = value-2;
                    }
                    if(game.board[i][j]==3){
                        value = (int)(value + 5 + numDefendNeighbor(i,j,game.board));
                        if(j==0 || j==7)
                            value = value+1;
                        if(i==0)
                            value = value+2;
                    }
                    if(game.board[i][j]==4){
                        value = (int)(value - 5 + numDefendNeighbor(i,j,game.board));
                        if(j==0 || j==7)
                            value = value-1;
                        if(i==7)
                            value = value-2;
                    }
                }
                else{
                    if(game.board[i][j]==1){
                        value = (int)(value - 3 + (0.5*i) + numDefendNeighbor(i,j,game.board));
                        if(j==0 || j==7)
                            value = value-1;
                        if(i==0)
                            value = value-2;
                    }
                    if(game.board[i][j]==2){
                        value = (int)(value + 3 + ((7-i)*0.5)+numDefendNeighbor(i,j,game.board));
                        if(j==0 || j==7)
                            value = value+1;
                        if(i==7)
                            value = value+2;
                    }
                    if(game.board[i][j]==3){
                        value = (int)(value - 5 + numDefendNeighbor(i,j,game.board));
                        if(j==0 || j==7)
                            value = value-1;
                        if(i==0)
                            value = value-2;
                    }
                    if(game.board[i][j]==4){
                        value = (int)(value + 5 + numDefendNeighbor(i,j,game.board));
                        if(j==0 || j==7)
                            value = value+1;
                        if(i==7)
                            value = value+2;
                    }
                }
            }
        }
        return value;
    }

    int numDefendNeighbor(int row,int col,int[][] board){
        int result = 0;
        if(board[row][col]==1){
            if(row+1<board.length&&col+1<board[0].length){
                if(board[row+1][col+1]==1||board[row+1][col+1]==3){
                    result++;
                }
            }
            if(row-1>=0&&col+1<board[0].length){
                if(board[row-1][col+1]==1||board[row-1][col+1]==3){
                    result++;
                }
            }
        }
        if(board[row][col]==2){
            if(row+1<board.length&&col-1>=0){
                if(board[row+1][col-1]==2||board[row+1][col-1]==4){
                    result++;
                }
            }
            if(row-1>=0&&col-1>=0){
                if(board[row-1][col-1]==2||board[row-1][col-1]==4){
                    result++;
                }
            }
        }
        if(board[row][col]==3){
            if(row+1<board.length&&col+1<board[0].length){
                if(board[row+1][col+1]==1 ||board[row+1][col+1]==3){
                    result++;
                }
            }
            if(row+1<board.length&&col-1>=0){
                if(board[row+1][col-1]==1||board[row+1][col-1]==3){
                    result++;
                }
            }
            if(row-1>=0 && col+1 < board[0].length){
                if(board[row-1][col+1]==1 ||board[row-1][col+1]==3){
                    result++;
                }
            }
            if(row-1>=0 && col-1 >= 0){
                if(board[row-1][col-1]==1 ||board[row-1][col-1]==3){
                    result++;
                }
            }
        }
        if(board[row][col]==4){
            if(row+1<board.length&&col+1<board[0].length){
                if(board[row+1][col+1]==2 ||board[row+1][col+1]==4){
                    result++;
                }
            }
            if(row+1<board.length&&col-1>=0){
                if(board[row+1][col-1]==2||board[row+1][col-1]==4){
                    result++;
                }
            }
            if(row-1>=0 && col+1 < board[0].length){
                if(board[row-1][col+1]==2 ||board[row-1][col+1]==4){
                    result++;
                }
            }
            if(row-1>=0 && col-1 >= 0){
                if(board[row-1][col-1]==2 ||board[row-1][col-1]==4){
                    result++;
                }
            }
        }
        return result;
    }


}

import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class main {
    public static void main(String[] args){
        Game game = new Game();

        game.newGame();
        Scanner myScan = new Scanner(System.in);
        System.out.println("choose player side : 1 or 2");
        int player = myScan.nextInt();
        game.setCurrentPlayer(player);
        Agent agent;
        if(player==1)
            agent = new Agent(2,1);
        else
            agent = new Agent(1,1);
        game.printBoard();
        while(!game.isFinish()){
            List<Move> avalMove = game.move(game);
            System.out.println("List of available Move");
            for(int i=0;i<avalMove.size();i++){
                Move temp = avalMove.get(i);
                System.out.println(i + " : ("+temp.startRow +","+temp.startCol+") -> ("+temp.endRow+","+temp.endCol+")");
            }
            System.out.println("choose the move");
            int move = myScan.nextInt();
            if(move<0||move>=avalMove.size()){
                System.out.println("Wrong input");
                System.out.println("change the move into 0");
                move = 0;
            }
            game.moved(avalMove.get(move),game.board);
            System.out.println("agent move");
            Move agentMove = agent.alphaBeta(game,15);
            game.moved(agentMove,game.board);
            System.out.println("agent moved : ("+agentMove.startRow +","+agentMove.startCol+") -> ("+agentMove.endRow+","+agentMove.endCol+")");
            game.printBoard();
            game.setCurrentPlayer(player);
        }
    }
}

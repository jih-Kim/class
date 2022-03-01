import java.util.ArrayList;

public class Move {
    public int startRow;
    public int startCol;
    public int endRow;
    public int endCol;
    public ArrayList<Integer> captureRow;
    public ArrayList<Integer> captureCol;
    public ArrayList<Integer> visitRow;
    public ArrayList<Integer> visitCol;
    public int[][] state;

    public Move(int startRow,int startCol,int endRow,int endCol, int[][] state){
        this.startRow = startRow;
        this.startCol = startCol;
        this.endRow = endRow;
        this.endCol = endCol;
        this.state = state;
        captureRow = new ArrayList();
        captureCol = new ArrayList();
        visitRow = new ArrayList();
        visitCol = new ArrayList();
    }

    public Move(Move move){
        this.startRow = move.startRow;
        this.startCol = move.startCol;
        this.state = move.state;
        this.endRow = move.endRow;
        this.endCol = move.endCol;
        captureRow = new ArrayList();
        captureCol = new ArrayList();
        visitRow = new ArrayList();
        visitCol = new ArrayList();
    }
}

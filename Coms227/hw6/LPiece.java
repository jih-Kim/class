package hw4;
/*
 * @author - Ji hoo Kim
 */
import api.Cell;
import api.Icon;
import api.Position;

public class LPiece extends AbstractPiece
{
	private int counter;
	private static final Position[] sequence =
		 {
		 new Position(0, 0),
		 new Position(0, 2),
		 };
	/**
	* Constructs a LPiece at the given position and givenIcon.
	* @param givenPosition
	* 	given Position value
	* @param givenIcon
	* 	given array of Icon
	*/
	public LPiece(Position givenPosition, Icon[] givenIcon) 
	{
		super(givenPosition, givenIcon);
		super.getCells()[0].setRowCol(0, 0);
		super.getCells()[1].setRowCol(0, 1);
		super.getCells()[2].setRowCol(1, 1);
		super.getCells()[3].setRowCol(2, 1);
		counter=0;
	}
	
	/**
	* Description copied from interface: Piece
	* Cycles the icons within the cells of this piece. 
	* Each icon is shifted forward to the next cell (in the original ordering of the cells). 
	* The last icon wraps around to the first cell.
	*/
	public void cycle()
	{
		super.cycle();
	}
	
	/**
	* Description copied from interface: Piece
	* Returns a deep copy of the Cell objects in this piece. 
	* The cell positions are relative to the upper-left corner of its bounding box.
	* getCells in interface Piece
	* @return copy of the cells in this piece
	*/
	public Cell[] getCells()
	{
		Cell[] tempCellArray = new Cell[super.getCells().length];
		for(int i=0;i<super.getCells().length;i++)
		{
			Position temp = new Position(super.getCells()[i].getRow(),super.getCells()[i].getCol());
	        Cell tempCell = new Cell(super.getCells()[i].getIcon(),temp);
			tempCellArray[i]=tempCell;
		}
		return tempCellArray;
	}
	
	/**
	 * Description copied from interface: Piece
	 * Returns a new array of Cell objects representing the icons in this piece with their absolute positions (relative positions plus position of bounding box).
	 * getCellsAbsolute in interface Piece
	 * @return copy of the cells in this piece, with absolute positions
	 */
	public Cell[] getCellsAbsolute()
	{
		return super.getCellAbsolute();
	}
	
	/**
	* Description copied from interface: Piece
	* Returns the position of this piece (upper-left corner of its bounding box).
	* getPosition in interface Piece
	* @return position of this shape
	*/
	public Position getPosition()
	{
		return super.getPosition();
	}
	
	/**
	* Description copied from interface: Piece
	* Sets the cells in this piece, making a deep copy of the given array.
	* setCells in interface Piece
	* @param givenCells
	* new cells for this piece
	*/
	public void setCells(Cell[] givenCells)
	{
		super.setCells(givenCells);
	}
	
	/**
	* Description copied from interface: Piece
	* Shifts the position of this piece down (increasing the row) by one.
	*  No bounds checking is done.
	*  shiftDown in interface Piece
	*/
	public void shiftDown()
	{
		super.shiftDown();
	}
	
	/**
	 * Description copied from interface: Piece
	 * Shifts the position of this piece left (decreasing the column) by one. 
	 * No bounds checking is done.
	 * shiftLeft in interface Piece
	 */
	public void shiftLeft()
	{
		super.shiftLeft();
	}
	
	/**
	 * Description copied from interface: Piece
	 * Shifts the position of this piece right (increasing the column) by one. 
	 * No bounds checking is done.
	 * shiftRight in interface Piece
	 */
	public void shiftRight()
	{
		super.shiftRight();
	}
	
	/**
	 * Description copied from interface: Piece
	 * Transforms this piece without altering its position according to the rules of the game to be implemented. 
	 * Typical operations would be rotation or reflection.
	 *  No bounds checking is done.
	 *  transform in interface Piece
	 */
	public void transform()
	{
		counter++;
		super.getCells()[0].setPosition(sequence[counter%2]);
	}
}

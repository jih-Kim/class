package hw4;
/*
 * @author - Ji hoo Kim
 */
import api.Cell;
import api.Icon;
import api.Piece;
import api.Position;

public abstract class AbstractPiece implements Piece
{
	private Cell[] data;
	private Position location;
	/**
	* Constructs a AbstractPiece at the given position and givenIcon.
	* @param givenPosition
	* 	given Position value
	* @param givenIcon
	* 	given array of Icon
	*/
	protected AbstractPiece(Position givenPosition, Icon[] givenIcon)
	{
		// TODO Auto-generated constructor stub
		data = new Cell[givenIcon.length];
		Position initial = new Position(0,0);
		for(int i=0;i<givenIcon.length;i++)
		{
			Cell temp = new Cell(givenIcon[i],initial);
			data[i]=temp;
		}
		location = givenPosition;
	}
	
	/**
	* Description copied from interface: Piece
	* Returns a deep copy of this object having the correct runtime type.
	* @return a deep copy of this object
	*/
	@Override
	public AbstractPiece clone()
	  {
	    try
	    {
	      // call the Object clone() method to create a shallow copy
	      AbstractPiece s = (AbstractPiece) super.clone();

	      // then make it into a deep copy (note there is no need to copy the position,
	      // since Position is immutable, but we have to deep-copy the cell array
	      // by making new Cell objects      
	      s.data = new Cell[data.length];
	      for (int i = 0; i < data.length; ++i)
	      {
	        Position temp = new Position(data[i].getRow(),data[i].getCol());
	        Cell tempCell = new Cell(data[i].getIcon(),temp);
	        s.data[i]=tempCell;
	      }
	      return s;
	    }
	    catch (CloneNotSupportedException e)
	    {
	      // can't happen, since we know the superclass is cloneable
	      return null;
	    }    
	  }
	
	/**
	* Description copied from interface: Piece
	* Cycles the icons within the cells of this piece. 
	* Each icon is shifted forward to the next cell (in the original ordering of the cells). 
	* The last icon wraps around to the first cell.
	*/
	public void cycle()
	{
		Icon temp = data[data.length-1].getIcon();
		for(int i=data.length-1;i>0;i--)
		{
			data[i].setIcon(data[i-1].getIcon());
		}
		data[0].setIcon(temp);
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
		return data;
	}
	
	/**
	* Description copied from interface: Piece
	* Returns the position of this piece (upper-left corner of its bounding box).
	* getPosition in interface Piece
	* @return position of this shape
	*/
	public Position getPosition()
	{
		return location;
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
		data = givenCells;
	}
	
	/**
	 * Description copied from interface: Piece
	 * Returns a new array of Cell objects representing the icons in this piece with their absolute positions (relative positions plus position of bounding box).
	 * getCellsAbsolute in interface Piece
	 * @return copy of the cells in this piece, with absolute positions
	 */
	protected Cell[] getCellAbsolute()
	{
		Cell[] tempData = new Cell[data.length];
		for(int i=0;i<data.length;i++)
		{
		    Position temp = new Position(data[i].getRow(),data[i].getCol());
		    Cell tempCell = new Cell(data[i].getIcon(),temp);
		    tempData[i]=tempCell;
			tempData[i].setRowCol(data[i].getRow()+location.row(), data[i].getCol()+location.col());
		}
		return tempData;
	}
	
	/**
	* Description copied from interface: Piece
	* Shifts the position of this piece down (increasing the row) by one.
	*  No bounds checking is done.
	*  shiftDown in interface Piece
	*/
	public void shiftDown()
	{
		Position tempPosition = new Position(location.row()+1,location.col());
		location = tempPosition;
	}
	
	/**
	 * Description copied from interface: Piece
	 * Shifts the position of this piece left (decreasing the column) by one. 
	 * No bounds checking is done.
	 * shiftLeft in interface Piece
	 */
	public void shiftLeft()
	{
		Position tempPosition = new Position(location.row(),location.col()-1);
		location = tempPosition;
	}

	/**
	 * Description copied from interface: Piece
	 * Shifts the position of this piece right (increasing the column) by one. 
	 * No bounds checking is done.
	 * shiftRight in interface Piece
	 */
	public void shiftRight()
	{
		Position tempPosition = new Position(location.row(),location.col()+1);
		location = tempPosition;
	}
	
	
}

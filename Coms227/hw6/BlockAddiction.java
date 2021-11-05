package hw4;
/*
 * @author - Ji hoo Kim
 */
import java.util.ArrayList;
import java.util.Collections;

import api.AbstractGame;
import api.Generator;
import api.Position;

public class BlockAddiction extends AbstractGame
{
	/**
	 *  Constructs a BlockAddiction at the given height, width, gen and preFillRows.
	 *  @param height
	 * 	given height value
	 *  @param width
	 * 	given width value
	 *  @param gen
	 *  given Generator value
	 *  @param preFillRows
	 *  number of preFilled Rows
	 */
	public BlockAddiction(int height, int width, Generator gen, int preFillRows)
	{
		super(height,width,gen);
		if(preFillRows>0)
		{
			for(int i=1;i<preFillRows+1;i++)
			{
				if(i%2==1)	//even number
				{
					for(int j=0;j<super.getWidth()/2;j++)
					{
						super.setBlock(super.getHeight()-i, super.getWidth()-1-2*j, gen.randomIcon());
					}
				}
				else	//odd number
				{
					for(int j=0;j<super.getWidth()/2;j++)
					{
						super.setBlock(super.getHeight()-i, super.getWidth()-2*(j+1), gen.randomIcon());
					}
				}
			}
		}
	}
	/**
	 *  Constructs a BlockAddiction at the given height, width and gen
	 *  @param height
	 * 	given height value
	 *  @param width
	 * 	given width value
	 *  @param gen
	 *  given Generator value
	 */
	public BlockAddiction(int height, int width, Generator gen)
	{
		super(height,width,gen);
	}
	
	/**
	 * Find the condition and return the result
	 * @param width
	 * given width value
	 * @param height
	 * given height value
	 * @param number
	 * number that matches the conditions
	 * @return
	 * return true if the condition is satisfy, else return false
	 */
	private boolean choice(int width, int height, int number)
	{
		boolean result = false;
		switch(number)
		{
		case 1 :	//width+1
			result = super.getIcon(width, height).equals(super.getIcon(width+1, height));
			break;
		case 2 :	//height+1
			result = super.getIcon(width, height).equals(super.getIcon(width, height+1));
			break;
		case 3 :	//width-1
			result = super.getIcon(width, height).equals(super.getIcon(width-1, height));
			break;
		case 4 :	//height-1
			result = super.getIcon(width, height).equals(super.getIcon(width, height-1));
			break;
		}
		return result;
	}
	/**
	 * Description copied from class: AbstractGame
	 * Returns a list of locations for all cells that form part of a collapsible set. 
	 * This list may contain duplicates.
	 * @return
	 * list of locations for positions to be collapsed
	 */
	public java.util.List<Position> determinePositionsToCollapse()
	{
		int count=0;
		Position temp;
		ArrayList<Position> result = new ArrayList<Position>();
		for(int width=0;width<super.getHeight();width++)
		{
			for(int height=0;height<super.getWidth();height++)
			{
				if(super.getIcon(width, height)!=null)
				{
					if(height==0)
					{
						if(width==0)
						{
							if(choice(width,height,1))
								count++;
							if(choice(width,height,2))
								count++;
						}
						else if(width==super.getHeight()-1)
						{
							if(choice(width,height,3))
								count++;
							if(choice(width,height,2))
								count++;
						}
						else
						{
						if(choice(width,height,1))
							count++;
						if(choice(width,height,2))
							count++;
						if(choice(width,height,3))
							count++;
						}
					}
				else if(width==0)
				{
					if(height==super.getWidth()-1)
					{
						if(choice(width,height,1))
							count++;
						if(choice(width,height,4))
							count++;
					}
					else
					{
					if(choice(width,height,1))
						count++;
					if(choice(width,height,2))
						count++;
					if(choice(width,height,4))
						count++;
					}
				}
				else if(height==super.getWidth()-1)
				{
					if(width==super.getHeight()-1)
					{
						if(choice(width,height,3))
							count++;
						if(choice(width,height,4))
							count++;
					}
					else
					{
					if(choice(width,height,1))
						count++;
					if(choice(width,height,3))
						count++;
					if(choice(width,height,4))
						count++;
					}
				}
				else if(width==super.getHeight()-1)
				{
					if(choice(width,height,2))
						count++;
					if(choice(width,height,3))
						count++;
					if(choice(width,height,4))
						count++;
				}
				else
				{
					if(choice(width,height,1))
						count++;
					if(choice(width,height,2))
						count++;
					if(choice(width,height,3))
						count++;
					if(choice(width,height,4))
						count++;
				}
				if(count>=2)
				{
					temp = new Position(width,height);
					if(!result.contains(temp))
						result.add(temp);
					if(height==0)
					{
						if(width==0)
						{
							if(choice(width,height,1))
							{
								temp = new Position(width+1,height);
								if(!result.contains(temp))
									result.add(temp);
							}
							if(choice(width,height,2))
							{
								temp = new Position(width,height+1);
								if(!result.contains(temp))
									result.add(temp);
							}
						}
						else if(width==super.getHeight()-1)
						{
							if(choice(width,height,3))
							{
								temp = new Position(width-1,height);
								if(!result.contains(temp))
									result.add(temp);
							}
							if(choice(width,height,2))
							{
								temp = new Position(width,height+1);
								if(!result.contains(temp))
									result.add(temp);
							}
						}
						else
						{
						if(choice(width,height,1))
						{
							temp = new Position(width+1,height);
							if(!result.contains(temp))
								result.add(temp);
						}
						if(choice(width,height,2))
						{
							temp = new Position(width,height+1);
							if(!result.contains(temp))
								result.add(temp);
						}
						if(choice(width,height,3))
						{
							temp = new Position(width-1,height);
							if(!result.contains(temp))
								result.add(temp);
						}
						}
					}
					else if(width==0)
					{
						if(height==super.getWidth()-1)
						{
							if(choice(width,height,1))
							{
								temp = new Position(width+1,height);
								if(!result.contains(temp))
									result.add(temp);
							}
							if(choice(width,height,4))
							{
								temp = new Position(width,height-1);
								if(!result.contains(temp))
									result.add(temp);
							}
						}
						else if(choice(width,height,1))
						{
							temp = new Position(width+1,height);
							if(!result.contains(temp))
								result.add(temp);
						}
						else
						{
						if(choice(width,height,2))
						{
							temp = new Position(width,height+1);
							if(!result.contains(temp))
								result.add(temp);
						}
						if(choice(width,height,4))
						{
							temp = new Position(width,height-1);
							if(!result.contains(temp))
								result.add(temp);
						}
						}
					}
					else if(height==super.getWidth()-1)
					{
						if(width==super.getHeight()-1)
						{
							if(choice(width,height,3))
							{
								temp = new Position(width-1,height);
								if(!result.contains(temp))
									result.add(temp);
							}
							if(choice(width,height,4))
							{
								temp = new Position(width,height-1);
								if(!result.contains(temp))
									result.add(temp);
							}
						}
						else
						{
						if(choice(width,height,1))
						{
							temp = new Position(width+1,height);
							if(!result.contains(temp))
								result.add(temp);
						}
						if(choice(width,height,3))
						{
							temp = new Position(width-1,height);
							if(!result.contains(temp))
								result.add(temp);
						}
						if(choice(width,height,4))
						{
							temp = new Position(width,height-1);
							if(!result.contains(temp))
								result.add(temp);
						}
						}
					}
					else if(width==super.getHeight()-1)
					{
						if(choice(width,height,2))
						{
							temp = new Position(width,height+1);
							if(!result.contains(temp))
								result.add(temp);
						}
						if(choice(width,height,3))
						{
							temp = new Position(width-1,height);
							if(!result.contains(temp))
								result.add(temp);
						}
						if(choice(width,height,4))
						{
							temp = new Position(width,height-1);
							if(!result.contains(temp))
								result.add(temp);
						}
					}
					else
					{
						if(choice(width,height,1))
						{
							temp = new Position(width+1,height);
							if(!result.contains(temp))
								result.add(temp);
						}
						if(choice(width,height,2))
						{
							temp = new Position(width,height+1);
							if(!result.contains(temp))
								result.add(temp);
						}
						if(choice(width,height,3))
						{
							temp = new Position(width-1,height);
							if(!result.contains(temp))
								result.add(temp);
						}
						if(choice(width,height,4))
						{
							temp = new Position(width,height-1);
							if(!result.contains(temp))
								result.add(temp);
						}
					}
					
					}
				}
			count=0;
			}
			Collections.sort(result);
			
		}
		return result;
	}
	
}

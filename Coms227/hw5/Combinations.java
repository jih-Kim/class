package mini3;

import java.util.Arrays;
/*
 * miniassignment 3
 * @author - Ji hoo Kim
 */
public class Combinations 
{
	public Combinations()
	{
		
	}

	public static int[][] getCombinations(int[] choices)
	{
		/*
		 * Calculate all the possible combinations of a set of ingredients, where the value of an ingredient is represented as a nonnegative integer
		 * The result is sorted according to ArrayComparator.
		 * @par - choices = an array of positive integers of length at least 1
		 * @return = a 2-D array that contains all the possible combinations of the given ingredient choices, where each row represents one unique combination.
		 */
		
		int[][] combos = new int[choices[0]][1];
		
		int count1=choices.length;
		if(count1==1)
		{
			for(int i=0;i<choices[0];i++)
			{
				combos[i][0]=i;
			}	
			
		return combos;
		}
		else
		{
			int[] temp = choices;
			int length = choices.length;
			choices = new int[choices.length-1];
			for(int i=0;i<choices.length;i++)
			{
				choices[i]=temp[i];
			}
			combos = getCombinations(choices);
			int size = temp[temp.length-1];
			int[][] combos2 = new int[combos.length*size][1];
			int i=0;
			int time=1;
			if(combos.length*size == combos.length)
			{
				for(int e=0;e<combos.length;e++)
				{
					combos2[e]=combos[e];
				}
			}
			else
			{
				for(int j=0;j<combos.length;j++)
				{
					int t;
					for(t=i;t<size*time;t++)
					{
					combos2[t]=combos[j];
					}
					time++;
					
					i=t;
					
				}
			}
			for(int t=0;t<combos2.length;t++)
			{
				combos2[t] = Arrays.copyOf(combos2[t], combos2[t].length+1);
			}
			int value = 0;
			for(int k=0;k<combos2.length;k++)
			{
				combos2[k][temp.length-1] = value;
				value++;
				if(value==temp[temp.length-1])
				{
					value=0;
				}
			}
			combos = combos2;
			
		}
		
		return combos;
	}
	
	
}

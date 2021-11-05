package hw3;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Scanner;

public class AsmFileUtil 
{
	public AsmFileUtil()
	{
		
	}
	
	public static void assembleAndWriteFile(java.lang.String filename, boolean annotatied) throws FileNotFoundException
	{
		File outFile = new File(filename+".mach227");
	    PrintWriter out = new PrintWriter(outFile);
	}
	
	public static java.util.ArrayList<java.lang.String> assembleFromFile(java.lang.String filename) throws FileNotFoundException
	{
		File file = new File(filename);
		Scanner scanfile = new Scanner(file);
		  ArrayList<String> words = new ArrayList<String>();
		while(scanfile.hasNext())
		{
			 words.add(scanfile.next());
		}
		return words;
	}
	
	public static int[] createMemoryImageFromFile(java.lang.String filename) throws FileNotFoundException
	{
		File file = new File(filename);
		Scanner scanfile = new Scanner(file);
		ArrayList<Integer> codes = new ArrayList<Integer>();
		while(scanfile.hasNextInt())
		{
			codes.add(scanfile.nextInt());
		}
		int[] code = new int[codes.size()];
		for(int i=0;i<codes.size();i++)
		{
			code[i]=codes.indexOf(i);
		}
		return code;
	}
}

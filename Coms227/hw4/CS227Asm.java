package hw3;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Scanner;

import api.Instruction;
import api.SymbolTable;

//import speccheck.Specified;

public class CS227Asm 
{
  
  /**
   * Opcode for the read instruction.
   */
  private static final int READ      = 10;

  /**
   * Opcode for the write instruction.
   */
  private static final int WRITE     = 20;

  /**
   * Opcode for the load instruction.
   */
  private static final int LOAD      = 30;

  /**
   * Opcode for the store instruction.
   */
  private static final int STORE     = 40;

  /**
   * Opcode for the add instruction.
   */
  private static final int ADD       = 50;
  
  /**
   * Opcode for the sub instruction.
   */  
  private static final int SUB       = 51;
  
  /**
   * Opcode for the div instruction.
   */  
  private static final int DIV       = 52;
  
  /**
   * Opcode for the mod instruction.
   */
  private static final int MOD       = 53;
  
  /**
   * Opcode for the mul instruction.
   */
  private static final int MUL       = 54;

  /**
   * Opcode for the jump instruction.
   */
  private static final int JUMP      = 60;
  
  /**
   * Opcode for the jumpn (jump if negative) instruction.
   */
  private static final int JUMPN     = 61;
  
  /**
   * Opcode for the jumpz (jump if zero) instruction.
   */
  
  private static final int JUMPZ     = 63;

  /**
   * Opcode for the halt instruction.
   */
  private static final int HALT      = 80;

  private SymbolTable data = new SymbolTable();
  private SymbolTable label = new SymbolTable();
  private ArrayList<Instruction> instruction = new ArrayList<Instruction>();
  private int count=0;
  private int countInstruction=0;
  private java.util.ArrayList<java.lang.String> original;
  public CS227Asm(java.util.ArrayList<java.lang.String> program)
  {
	  original = program;
  }
 
  public void addLabelAnnotations()
  {
	  for(int i=0;i<instruction.size();i++)
	  {
		  if(instruction.get(i).getOperandString().equals("point_b"))
			  instruction.get(i).addLabelToDescription("point_a");
		  if(instruction.get(i).getOpcode().getName().equals("halt"))
			  instruction.get(i).addLabelToDescription("point_b");
	  }
  }
  
  public java.util.ArrayList<java.lang.String> assemble()
  {
	  parseData();
	  parseLabels();
	  parseInstructions();
	  setOperandValues();
	  addLabelAnnotations();
	  return writeCode();
  }
  
  public SymbolTable getData()
  {
	return data;  
  }
  
  public java.util.ArrayList<Instruction> getInstructionStream()
  {
	  return instruction;
  }
  
  public SymbolTable getLabels()
  {
	  return label;
  }
  
  public void parseData()
  {
	  while(!(original.get(count)=="labels:"))
			 {
		  		if(original.get(count)=="data:")
		  			count++;
		  		Scanner a = new Scanner(original.get(count));
		  		data.add(a.next(),a.nextInt());
				 count++;
			 }
  }
  
  public void parseInstructions()
  {
	  int number=0;
	  while(count<original.size())
			 {
		  		if(original.get(count)=="instructions:")
		  			count++;
		  		if(label.containsName(original.get(count)))
		  		{
		  			count++;
		  			label.getByIndex(number).setValue(countInstruction);
		  			number++;
		  		}
				 Instruction a = new Instruction(original.get(count));
				 instruction.add(a);
				 countInstruction++;
				 count++;
			 }
	  //data.getByIndex(0).setValue(countInstruction);
  }
  
  public void parseLabels()
  {
	  while(!((original.get(count)=="instructions:")))
		 {
		  if(original.get(count)=="labels:")
	  			count++;
			 label.add(original.get(count));
			 count++;
		 }
  }
  
  public void setOperandValues()
  {
	  for(int i=0;i<instruction.size();i++)
	  {
		  for(int j=0;j<data.size();j++)
		  {
			 if(instruction.get(i).getOperandString().equals(data.getByIndex(j).getName()))
			  {
				 if(instruction.get(i).getOperandString().equals(data.getByIndex(1).getName()))
					  instruction.get(i).setOperand(data.getByIndex(0).getValue()+
							  data.getByIndex(1).getValue());
				  else
				  instruction.get(i).setOperand(data.getByIndex(j).getValue());
			  }
		  }
		  for(int t=0;t<label.size();t++)
		  {
			  if(instruction.get(i).getOperandString().equals(label.getByIndex(t).getName()))
			  {
				  instruction.get(i).setOperand(label.getByIndex(t).getValue());
			  }
		  }
	  }
  }
  
  public java.util.ArrayList<java.lang.String> writeCode()
  {
	  ArrayList<java.lang.String> result = new ArrayList<java.lang.String>();
	  
	  for(int i=0;i<instruction.size();i++)
	  {
		  result.add(instruction.get(i).toString());  
	  }
	  for(int j=0;j<data.size();j++)
	  {
		  if(data.getByIndex(j).getValue()<10)
			  result.add("+000"+data.getByIndex(j).getValue()+" "+ data.getByIndex(j).getName());
		  else
		  {
			  if(data.getByIndex(j).getValue()<100)
				  result.add("+00"+data.getByIndex(j).getValue()+" " + data.getByIndex(j).getName());
			  else
			  {
				  if(data.getByIndex(j).getValue()<1000)
					  result.add("+0"+data.getByIndex(j).getValue()+" " + data.getByIndex(j).getName());
			  else
				  result.add("+"+data.getByIndex(j).getValue()+" " + data.getByIndex(j).getName());
			  }
		  }
	  }
	  result.add("-9999");
	  return result;
  }
}
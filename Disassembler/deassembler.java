package pa2;

import java.io.*;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Scanner;

public class deassembler {
    public static void main(String args[]){
            String filename;
            if(args.length == 0){
                Scanner input = new Scanner(System.in);
                System.out.println("Enter the filename");
                filename = input.nextLine();
            }
            else{
                filename = args[0];
            }

            int num = -1;
            ArrayList<Integer> insN = new ArrayList<Integer>();
            ArrayList<String> ins = new ArrayList<String>();
            ArrayList<String> finalData = new ArrayList<String>();
            String inst="";
            byte[] array = new byte[10000];
            try{
                InputStream input = new FileInputStream(filename);
                input.read(array);
                //byte to string
                for(int i=0;i<array.length;i++){
                    int test = (array[i] & 0xFF);
                    if(i%4==0 && i!=0){
                        ins.add(inst);
                        inst = "";
                    }
                    inst = inst + convert(test);
                }
                input.close();
            }
            catch(Exception e){
                e.getStackTrace();
            }
            for(int i=0;i<ins.size();i++){
                String instruction = ins.get(i);
                num = checkIns(instruction,finalData);
                decode(num,instruction,finalData);
            }
            change(finalData);
            System.out.println();
            for(int j=0;j<finalData.size();j++)
                System.out.println(finalData.get(j));
    }

    public static String convert(int a){
        String result = "";
        while(true){
            if(a>=128){
                a = a-128;
                result = result + "1";
            }
            else{
                result = result + "0";
            }
            if(a>=64){
                a = a-64;
                result = result + "1";
            }
            else{
                result = result + "0";
            }
            if(a>=32){
                a = a-32;
                result = result + "1";
            }
            else{
                result = result + "0";
            }
            if(a>=16){
                a = a-16;
                result = result + "1";
            }
            else{
                result = result + "0";
            }
            if(a>=8){
                a = a-8;
                result = result + "1";
            }
            else{
                result = result + "0";
            }
            if(a>=4){
                a = a-4;
                result = result + "1";
            }
            else{
                result = result + "0";
            }
            if(a>=2){
                a = a-2;
                result = result + "1";
            }
            else{
                result = result + "0";
            }
            if(a==1){
                a = a-1;
                result = result + "1";
                break;
            }
            else{
                result = result + "0";
                break;
            }
        }
        return result;
    }

    public static void change(ArrayList<String> fin){
        int count = 0;
        for(int i=0;i<fin.size();i++){
            if(fin.get(i).contains("B    ")){
                String index = fin.get(i).substring(fin.get(i).length()-3,fin.get(i).length());
                if(index.contains("  ")){
                    index = index.substring(2);
                }
                else if(index.contains(" ")) {
                    index = index.substring(1,3);
                }
                //calcualte the index
                int indexN = Integer.parseInt(index);
                int target = i+indexN;
                String newSt = "B   label "+count;
                if(indexN < 0){
                    for(int t=target;t<i;t++){
                        if(fin.get(t).contains(":"))
                            target--;
                    }
                }
                if(fin.get(target-1).contains(":")){
                    StringBuilder sb = new StringBuilder();
                    for(int l=0;l<fin.get(target-1).length();l++){
                        if(Character.isDigit(fin.get(target-1).charAt(l)))
                            sb.append(fin.get(target-1).charAt(l));
                    }
                    newSt = "B   label "+sb;
                    fin.set(i,newSt);
                }
                else{
                    fin.set(i,newSt);
                    fin.add(fin.get(fin.size()-1));
                    for(int j=fin.size()-1;j>=target;j--){
                        fin.set(j,fin.get(j-1));
                    }
                    fin.set(target,"label "+count+":");
                }
                count++;
            }//finish branch
            if(fin.get(i).contains("CBZ")||fin.get(i).contains("CBNZ")||fin.get(i).contains("B.")){
                int indexNu = 0;
                StringBuilder sb = new StringBuilder();
                for(int j=0;j<fin.get(i).length();j++){
                    if(Character.isDigit(fin.get(i).charAt(j))&&!(fin.get(i).charAt(j-1) == 'X') &&!(fin.get(i).charAt(j-2) == 'X'))
                        sb.append(fin.get(i).charAt(j));
                }
                String sbs = "" + sb;
                indexNu = Integer.parseInt(sbs);
                int target = i + indexNu;
                String newM = fin.get(i).substring(0,fin.get(i).length()-4) + "   label "+count;
                fin.set(i,newM);
                fin.add(fin.get(fin.size()-1));
                for(int j=i;j<target;j++){
                    if(fin.get(j).contains(":"))
                        target++;
                }
                for(int j=fin.size()-1;j>=target;j--){
                    fin.set(j,fin.get(j-1));
                }
                fin.set(target,"label "+count+":");
                count++;
            }
        }
    }


    public static int checkIns(String inst,ArrayList<String> fin){
        String tempOpc = inst.substring(0,6);
        String temp;
        if(tempOpc.equals("000101")){
            temp = "B    ";
            fin.add(temp);
            //System.out.print("B   ");
            return 4;                   //B
        }
        if(tempOpc.equals("100101")){
            temp = "BL   ";
            fin.add(temp);
            //System.out.print("BL   ");
            return 4;                   //BL
        }
        tempOpc = inst.substring(0,8);
        if(tempOpc.equals("01010100")){
            temp = "B.";
            fin.add(temp);
            //System.out.print("B.");
            return 5;                   //B.cond
        }
        if(tempOpc.equals("10110100")){
            temp = "CBZ   ";
            fin.add(temp);
            //System.out.print("CBZ   ");
            return 5;                   //CBZ
        }
        if(tempOpc.equals("10110101")) {
            temp = "CBNZ   ";
            fin.add(temp);
            //System.out.print("CBNZ   ");
            return 5;                   //CBNZ
        }
        tempOpc = inst.substring(0,10);
        if(tempOpc.equals("1001000100")){
            temp = "ADDI   ";
            fin.add(temp);
            //System.out.print("ADDI   ");
            return 2;                   //ADDI
        }
        if(tempOpc.equals("1001001000")){
            temp = "ANDI   ";
            fin.add(temp);
            //System.out.print("ANDI   ");
            return 2;                   //ANDI
        }

        if(tempOpc.equals("1011001000")){
            temp = "ORRI   ";
            fin.add(temp);
            //System.out.print("ORRI   ");
            return 2;                   //ORRI
        }
        if(tempOpc.equals("1101000100")){
            temp = "SUBI   ";
            fin.add(temp);
            //System.out.print("SUBI   ");
            return 2;                   //SUBI
        }
        if(tempOpc.equals("1101001000")){
            temp = "EORI   ";
            fin.add(temp);
            //System.out.print("EORI   ");
            return 2;                   //EORI
        }
        if(tempOpc.equals("1111000100")){
            temp = "SUBIS   ";
            fin.add(temp);
            //System.out.print("SUBIS   ");
            return 2;                   //SUBIS
        }
        tempOpc = inst.substring(0,11);
        if(tempOpc.equals("10001010000")){
            temp = "AND   ";
            fin.add(temp);
            //System.out.print("AND   ");
            return 1;                   //AND
        }
        if(tempOpc.equals("10001011000")){
            temp = "ADD   ";
            fin.add(temp);
            //System.out.print("ADD   ");
            return 1;                   //ADD
        }
        if(tempOpc.equals("10011011000")){
            temp = "MUL   ";
            fin.add(temp);
            //System.out.print("MUL   ");
            return 1;                   //MUL
        }
        if(tempOpc.equals("10101010000")){
            temp = "ORR   ";
            fin.add(temp);
            //System.out.print("ORR   ");
            return 1;                   //ORR
        }
        if(tempOpc.equals("11001010000")){
            temp = "EOR   ";
            fin.add(temp);
            //System.out.print("EOR   ");
            return 1;                   //EOR
        }
        if(tempOpc.equals("11001011000")){
            temp = "SUB   ";
            fin.add(temp);
            //System.out.print("SUB   ");
            return 1;                   //SUB
        }
        if(tempOpc.equals("11010011010")){
            temp = "LSR   ";
            fin.add(temp);
            //System.out.print("LSR   ");
            return 1;                   //LSR
        }
        if(tempOpc.equals("11010011011")){
            temp = "LSL   ";
            fin.add(temp);
            //System.out.print("LSL   ");
            return 1;                   //LSL
        }
        if(tempOpc.equals("11010110000")){
            temp = "BR   ";
            fin.add(temp);
            //System.out.print("BR   ");
            return 1;                   //BR
        }
        if(tempOpc.equals("11101011000")){
            temp = "SUBS   ";
            fin.add(temp);
            //System.out.print("SUBS   ");
            return 1;                   //SUBS
        }
        if(tempOpc.equals("11111000000")){
            temp = "STUR   ";
            fin.add(temp);
            //System.out.print("STUR   ");
            return 3;                   //STUR
        }
        if(tempOpc.equals("11111000010")){
            temp = "LDUR   ";
            fin.add(temp);
            //System.out.print("LDUR   ");
            return 3;                   //LDUR
        }
        if(tempOpc.equals("11111111101")){
            temp = "PRNT   ";
            fin.add(temp);
            //System.out.print("PRNT   ");
            return 1;                   //PRNT
        }
        if(tempOpc.equals("11111111100")){
            temp = "PRNL   ";
            fin.add(temp);
            //System.out.print("PRNL   ");
            return 1;                   //PRNL
        }
        if(tempOpc.equals("11111111110")){
            temp = "DUMP   ";
            fin.add(temp);
            //System.out.print("DUMP   ");
            return 1;                   //DUMP
        }
        if(tempOpc.equals("11111111111")){
            temp = "HALT   ";
            fin.add(temp);
            //System.out.print("HALT   ");
            return 1;                   //HALT
        }
        return -1;
    }

    public static void decode(int num, String ins, ArrayList<String> fin){
        switch(num){
            case 1:                     //R type
                String op = ins.substring(0,11);
                String rm = ins.substring(11,16);
                String shamt = ins.substring(16,22);
                String rn = ins.substring(22,27);
                String rd = ins.substring(27,32);
                long rmNum = binaryCon(rm);
                long shamtNum = binaryCon(shamt);
                long rnNum = binaryCon(rn);
                long rdNum = binaryCon(rd);
                String data = fin.get(fin.size()-1);
                if(op.equals("11101010000")){
                    data = data + rnNum;
                    fin.set(fin.size()-1,data);
                    //System.out.println(rnNum);
                }
                else if(op.equals("11010011010")||op.equals("11010011011")){
                    data = data + "X" + rdNum + ",   ";
                    data = data + "X" + rnNum + ",   ";
                    data = data + "#" + shamtNum;
                    fin.set(fin.size()-1,data);
                }
                else if(op.equals("11111111101")){
                    data = data +"X" + rdNum;
                    fin.set(fin.size()-1,data);
                }
                else if(op.equals("11111111100")||op.equals("11111111110")||op.equals("11111111111")){
                }
                else{
                    data = data + "X" + rdNum + ",   ";
                    data = data + "X" + rnNum + ",   ";
                    data = data + "X" + rmNum;
                    fin.set(fin.size()-1,data);
                    //System.out.print("X"+rdNum+",   ");
                    //System.out.print("X"+rnNum+",   ");
                    //System.out.println("X"+rmNum);
                }
                break;
            case 2:
                String imme = ins.substring(10,22);
                String rn2 = ins.substring(22,27);
                String rd2 = ins.substring(27,32);
                long immeNum = binaryCon(imme);
                long rn2Num = binaryCon(rn2);
                long rd2Num = binaryCon(rd2);
                data = fin.get(fin.size()-1);
                data = data + "X" + rd2Num + ",   X"+rn2Num + ",   #"+immeNum;
                fin.set(fin.size()-1,data);
                //System.out.print("X"+rd2Num+",   ");
                //System.out.print("X"+rn2Num+",   ");
                //System.out.println("#"+immeNum);
                break;
            case 3:
                String add = ins.substring(11,20);
                String op2 = ins.substring(20,22);
                String rn3 = ins.substring(22,27);
                String rt3 = ins.substring(27,32);
                long addN = binaryCon(add);
                long opN = binaryCon(op2);
                long rn3N = binaryCon(rn3);
                long rt3N = binaryCon(rt3);
                data = fin.get(fin.size()-1);
                data = data + "X"+rt3N + ",   [X"+rn3N + ",   #"+addN + "]";
                fin.set(fin.size()-1,data);
                //System.out.print("X"+rt3N+",   ");
                //System.out.print("[X"+rn3N +",   ");
                //System.out.println("#"+addN+"]");
                break;
            case 4:
                String addr = ins.substring(6,32);
                negIns(addr,fin);
                break;
            default:
                String opc = ins.substring(0,8);
                String addre = ins.substring(8,27);
                String rt4 = ins.substring(27,32);
                long rt4N = binaryCon(rt4);
                int ch = (int)rt4N;
                if(opc.equals("01010100")){
                     switch(ch){
                         case 0:
                             data = fin.get(fin.size()-1);
                             data = data + "EQ   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("EQ   ");
                             negIns(addre,fin);
                             break;
                         case 1:
                             data = fin.get(fin.size()-1);
                             data = data + "NE   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("NE   ");
                             negIns(addre,fin);
                             break;
                         case 2:
                             data = fin.get(fin.size()-1);
                             data = data + "HS   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("HS   ");
                             negIns(addre,fin);
                             break;
                         case 3:
                             data = fin.get(fin.size()-1);
                             data = data + "LO   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("LO   ");
                             negIns(addre,fin);
                             break;
                         case 4:
                             data = fin.get(fin.size()-1);
                             data = data + "MI   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("MI   ");
                             negIns(addre,fin);
                             break;
                         case 5:
                             data = fin.get(fin.size()-1);
                             data = data + "PL   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("PL   ");
                             negIns(addre,fin);
                             break;
                         case 6:
                             data = fin.get(fin.size()-1);
                             data = data + "VS   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("VS   ");
                             negIns(addre,fin);
                             break;
                         case 7:
                             data = fin.get(fin.size()-1);
                             data = data + "VC   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("VC   ");
                             negIns(addre,fin);
                             break;
                         case 8:
                             data = fin.get(fin.size()-1);
                             data = data + "HI   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("HI   ");
                             negIns(addre,fin);
                             break;
                         case 9:
                             data = fin.get(fin.size()-1);
                             data = data + "LS   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("LS   ");
                             negIns(addre,fin);
                             break;
                         case 10:
                             data = fin.get(fin.size()-1);
                             data = data + "GE   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("GE   ");
                             negIns(addre,fin);
                             break;
                         case 11:
                             data = fin.get(fin.size()-1);
                             data = data + "LT   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("LT   ");
                             negIns(addre,fin);
                             break;
                         case 12:
                             data = fin.get(fin.size()-1);
                             data = data + "GT   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("GT   ");
                             negIns(addre,fin);
                             break;
                         default:
                             data = fin.get(fin.size()-1);
                             data = data + "LE   ";
                             fin.set(fin.size()-1,data);
                             //System.out.print("LE   ");
                             negIns(addre,fin);
                     }
                }
                else{
                    data = fin.get(fin.size()-1);
                    data = data + "X" + rt4N + ",   ";
                    fin.set(fin.size()-1,data);
                    //System.out.print("X"+rt4N+",   ");
                    negIns(addre,fin);
                }
        }
    }

    public static long binaryCon(String insN){
        ArrayList<Character> temp = new ArrayList<Character>();
        for(int i=insN.length()-1;i>=0;i--){
            temp.add((Character)insN.charAt(i));
        }
        long result = 0;
        for(int i=0;i<temp.size();i++){
            long two = (long)Math.pow(2,i);
            result = result + two*(Character.getNumericValue((char)temp.get(i)));
        }
        return result;
    }

    public static void negIns(String ins,ArrayList<String> fin){
        ArrayList<Integer> temp = new ArrayList<Integer>();
        boolean neg = false;
        for(int i=0;i<ins.length();i++){
            temp.add((Integer)Character.getNumericValue(ins.charAt(i)));
        }
        if((int)temp.get(0)==1){
            neg=true;
            for(int i=0;i<temp.size();i++){
                if((int)temp.get(i)==0){
                    temp.set(i,1);
                }
                else
                    temp.set(i,0);
            }
            int temp2 = (int)temp.get(temp.size()-1)+1;
            temp.set(temp.size()-1,temp2);
        }
        for(int i=temp.size()-1;i>0;i--){
            if((int)temp.get(i)==2){
                temp.set(i,0);
                temp.set(i-1,(int)temp.get(i-1)+1);
            }
        }
        StringBuffer sb = new StringBuffer();
        for(int i=0;i<temp.size();i++){
            sb.append(temp.get(i));
        }
        long result = binaryCon(sb.toString());
        if(neg)
            result = -result;
        String data = fin.get(fin.size()-1);
        data = data + result;
        fin.set(fin.size()-1,data);
        //System.out.println(result);
    }
}

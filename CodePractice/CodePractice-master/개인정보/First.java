import java.util.HashMap;
import java.util.ArrayList;
import java.util.Arrays;

public class First {

    public static void main(String[] args)
    {
        First temp = new First();
        String today = "2021.12.08";
        String[] terms = {"A 18"};
        String[] privacies = {"2020.06.08 A"};
        int[] answer = temp.solution(today,terms,privacies);
        System.out.println(Arrays.toString(answer));
    }

    public int[] solution(String today, String[] terms, String[] privacies) {
            HashMap<Character,Integer> data = changeTHash(terms);
            Date t = changeTDate(today);
            HashMap<Integer,Date> table = new HashMap();
            //change privacies to table and add month so we can compare
            for(int i=0;i<privacies.length;i++){
                Date temp = changeTDate(privacies[i].substring(0,10));
                temp.addMonth(data.get(privacies[i].charAt(privacies[i].length()-1)));
                table.put(i,temp);
            }
            //compare and find if today exceed the table
            ArrayList<Integer> tempAns = new ArrayList();
            for(int i=0;i<privacies.length;i++){
                if(!t.compare(table.get(i))){
                    tempAns.add(i+1);
                }
            }
            //change answer into int array
            int[] answer = new int[tempAns.size()];
            for(int i=0;i<tempAns.size();i++){
                answer[i]=tempAns.get(i);
            }
            return answer;
        }

        private Date changeTDate(String d){
            return new Date(Integer.valueOf(d.substring(0,4)),Integer.valueOf(d.substring(5,7)),Integer.valueOf(d.substring(8,10)));
        }

        private HashMap<Character,Integer> changeTHash(String[] target){
            HashMap<Character,Integer> anw = new HashMap<Character,Integer>();
            for(int i=0;i<target.length;i++){
                String temp = target[i];
                anw.put(temp.charAt(0),Integer.valueOf(temp.substring(2,temp.length())));
            }
            return anw;
        }

        class Date{
            private int year;
            private int month;
            private int day;

            public Date(int y,int m,int d){
                year = y;
                month = m;
                day = d;
            }

            public void addMonth(int m){
                if(month+m>12){
                    //24,36,48....
                    if((month+m)%12==0){
                        year = year+(month+m)/12-1;
                        month = 12;
                    }
                    else{
                        year = year+(month+m)/12;
                        month = (month+m)%12;
                    }
                }
                else
                    month = month+m;
            }

            public int getYear(){
                return year;
            }

            public int getMonth(){
                return month;
            }

            public int getDay(){
                return day;
            }

            public void setYear(int y){
                year = y;
            }

            public void setMonth(int m){
                month = m;
            }

            public void setDay(int d){
                day = d;
            }

            //return false is d is less then own
            //otherwise return true
            public boolean compare(Date d){
                if(d.getYear()<year)
                    return false;
                else if(d.getYear()==year){
                    if(d.getMonth()<month)
                        return false;
                    else if(d.getMonth()==month) {
                        if(d.getDay()<=day)
                            return false;
                    }
                }
                return true;
            }
        }
}

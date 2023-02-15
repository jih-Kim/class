import java.util.ArrayList;
import java.util.Arrays;


public class Third {

    public static void main(String[] args) {
        int[][] user = {{40, 2900}, {23, 10000}, {11, 5200}, {5, 5900}, {40, 3100}, {27, 9200}, {32, 6900}};
        int[] emoticons = {1300,1500,1600,4900};
        Third third = new Third();
        int[] result;
        result = third.solution(user,emoticons);

    }

    public int[] solution(int[][] users, int[] emoticons) {
        int[] answer = {0,0};

        ArrayList<int[]> disTotal = new ArrayList();
        int[] discount = {1,2,3,4};
        permutation(discount,new int[emoticons.length],0,emoticons.length,disTotal);

        for(int i=0;i<disTotal.size();i++){
            //System.out.println(i + ": " + Arrays.toString(disTotal.get(i)));
        }

        ArrayList<int[]> calTotal;

        calTotal = disTotal(emoticons,users,disTotal);

        for(int i=0;i<disTotal.size();i++){
            //System.out.println(Arrays.toString(calTotal.get(i)));
        }


        for(int i=0;i<calTotal.size();i++){
            int[] temp = calTotal.get(i);
            if(temp[0]>answer[0]){
                answer=temp;
            }
            else if(temp[0]==answer[0]){
                if(temp[1]>answer[1])
                    answer=temp;
            }
        }
        System.out.println(Arrays.toString(answer));

        return answer;
    }
    //data를 이용해서 계산후 결과값을 내뱉음
    //ex user = 2
    //계산후 0,0
    //      10500,4200 ....
    private ArrayList<int[]> disTotal(int[] emoticons, int[][] user, ArrayList<int[]> data){
        ArrayList<int[]> result = new ArrayList();
        int checkLength=0;
        //int[] calTotal = new int[user.length];
        int[] calTotal = {0,0};
        //data arraylist를 한번씩 체크
        //ex discount 10%, 10% ==> 1,1
        //   discount 20%, 30% ==> 2,3
        for(int i=0;i<data.size();i++){
            if(i==247){
                int k =1;
            }
            int[] temp = data.get(i);   //1,1
            //user의 길이만큼 실행
            //결과값이 0원, 0원 ==> 0,0
            //      9600원, 9600원 ==> 9600,9600
            for(int j=0;j<user.length;j++){
                //dis는 기준값
                //temp의 값이 기준값보다 작으면 0원 처리
                int dis = user[j][0];
                //계산!
                int tempCal = calculate(temp,dis,emoticons);
                if(tempCal>=user[j][1]){
                    calTotal[0]=calTotal[0]+1;
                }
                else
                    calTotal[1]=calTotal[1]+tempCal;
            }
            result.add(calTotal.clone());
            checkLength++;
            calTotal[0]=0;
            calTotal[1]=0;
        }
        return result;
    }
    //data = [1,1], [1,2] ...
    //data = 할인율에 대한 정보
    private int calculate(int[] data, int standard, int[] emoticons){
        int result=0;
        //data의 개수는 이모티콘의 개수
        for(int i=0;i<data.length;i++){
            //standard 25 data[i] 30
            if(standard<=data[i]*10){
                result = result + emoticons[i]/10*(10-data[i]);
            }
        }

        return result;
    }

    //중복 순열을 이용해서 모든 경우의 수를 data에 저장
    private void permutation(int[] target,int[] result,int cnt,int length,ArrayList<int[]> data){
        if(cnt==length){
            data.add(result.clone());
            return;
        }
        for(int i=0;i<target.length;i++){
            result[cnt]=target[i];
            permutation(target,result,cnt+1,length,data);
        }
    }

}

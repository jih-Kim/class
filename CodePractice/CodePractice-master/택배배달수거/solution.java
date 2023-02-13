class Solution {
    public long solution(int cap, int n, int[] deliveries, int[] pickups) {
        long answer = 0;
        int d =0;
        int p =0;
        for(int i=n-1;i>=0;i--){
            int cnt = 0;
            d-=deliveries[i];
            p-=pickups[i];

            while(d<0||p<0){
                d+=cap;
                p+=cap;
                cnt+=1;
            }
            answer= answer + (i+1)*2*cnt;
        }
        return answer;
    }
    
}
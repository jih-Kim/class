/*
Given a string s, return the longest palindromic substring in s.
Example 1:
Input: s = "babad"
Output: "bab"
Note: "aba" is also a valid answer.

Example 2:
Input: s = "cbbd"
Output: "bb"

Example 3:
Input: s = "a"
Output: "a"

Example 4:
Input: s = "ac"
Output: "a"

Constraints:
1 <= s.length <= 1000
s consist of only digits and English letters.
 */
public class Palindromic {
    public static void main(String[] args){
        Palindromic p = new Palindromic();
        String input = "babad";
        String result = p.longestPalindrome(input);
        System.out.println(result);
    }
        public String longestPalindrome(String s) {
            String answer = "";
            String temp = "";
            for(int i=0;i<s.length();i++){
                //two same order
                if(i<s.length()-1 && s.charAt(i)==s.charAt(i+1)){
                    int k=1;
                    while(true){
                        if(i-k<0||i+1+k>=s.length())
                            break;
                        if(s.charAt(i-k)==s.charAt(i+1+k))
                            k++;
                        else
                            break;
                    }
                    temp = s.substring(i-k+1,i+k+1);
                    if(answer.length()<temp.length()){
                        answer = temp;
                        temp = "";
                    }
                }
                //sandwich
                if(i>0 && i<s.length()-1 &&s.charAt(i-1)==s.charAt(i+1)){
                    int k =1;
                    while(true){
                        if(i-k<0 || i+k>=s.length())
                            break;
                        if(s.charAt(i-k) == s.charAt(i+k))
                            k++;
                        else
                            break;
                    }
                    temp = s.substring(i-k+1,i+k);
                    if(answer.length()<temp.length()){
                        answer = temp;
                        temp = "";
                    }
                }

            }
            if(answer.equals(""))
                answer = s.substring(0,1);
            return answer;
        }
}

import java.util.HashMap;
import java.util.Map;

/*
Given a string s, find the length of the longest substring without repeating characters.

Example 1:
Input: s = "abcabcbb"
Output: 3
Explanation: The answer is "abc", with the length of 3.

Example 2:
Input: s = "bbbbb"
Output: 1
Explanation: The answer is "b", with the length of 1.

Example 3:
Input: s = "pwwkew"
Output: 3
Explanation: The answer is "wke", with the length of 3.
Notice that the answer must be a substring, "pwke" is a subsequence and not a substring.

Example 4:
Input: s = ""
Output: 0

Constraints:
0 <= s.length <= 5 * 104
s consists of English letters, digits, symbols and spaces.
 */

public class LongSubString {
    public static void main(String[] args){
        LongSubString lss = new LongSubString();
        String input = "abcabcbb";
        int result = lss.lengthOfLongestSubstring(input);
        System.out.println(result);
    }
        public int lengthOfLongestSubstring(String s) {
            Map<Character,Integer> hm = new HashMap<>();
            int max = 0;
            int j = 0;
            int i = 0;
            if(s.length()==0)
                return 0;
            while(i<=s.length()){
                if(i==s.length() && !hm.isEmpty()){
                    if(max<hm.size())
                        max = hm.size();
                    break;
                }
                else if(hm.containsKey(s.charAt(i))){
                    if(max < i-j)
                        max = i-j;
                    hm.remove(s.charAt(j),0);
                    j++;
                }
                else{
                    hm.put(s.charAt(i),0);
                    i++;
                }
            }
            return max;
        }
}

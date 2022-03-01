/*
Given a string s consisting of some words separated by some number of spaces, return the length of the last word in the string.
A word is a maximal substring consisting of non-space characters only.

Example 1:
Input: s = "Hello World"
Output: 5
Explanation: The last word is "World" with length 5.

Example 2:
Input: s = "   fly me   to   the moon  "
Output: 4
Explanation: The last word is "moon" with length 4.

Example 3:
Input: s = "luffy is still joyboy"
Output: 6
Explanation: The last word is "joyboy" with length 6.

Constraints:
1 <= s.length <= 104
s consists of only English letters and spaces ' '.
There will be at least one word in s.
 */
public class LengthLastWord {
    public static void main(String[] args){
        LengthLastWord l = new LengthLastWord();
        String input = "Hello world";
        System.out.println(l.lengthOfLastWord(input));
    }
        public int lengthOfLastWord(String s) {
            int index = s.length();
            int length=0;
            while(index>0){
                index--;
                if(s.charAt(index)!=' '){
                    length++;
                }
                else if(length>0)
                    return length;
            }
            return length;
        }
}

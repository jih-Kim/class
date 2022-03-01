import java.util.ArrayList;
/*
Given a string s containing just the characters '(', ')', '{', '}', '[' and ']', determine if the input string is valid.
An input string is valid if:
Open brackets must be closed by the same type of brackets.
Open brackets must be closed in the correct order.

Example 1:
Input: s = "()"
Output: true

Example 2:
Input: s = "()[]{}"
Output: true

Example 3:
Input: s = "(]"
Output: false

Example 4:
Input: s = "([)]"
Output: false

Example 5:
Input: s = "{[]}"
Output: true

Constraints:
1 <= s.length <= 104
s consists of parentheses only '()[]{}'.
 */

public class Parentheses {
    public static void main(String[] args){
        Parentheses p = new Parentheses();
        String input = "{[]}";
        System.out.println(p.isValid(input));
    }

    public boolean isValid(String s) {
        ArrayList<Character> a = new ArrayList<Character>();
        for(int i=0;i<s.length();i++){
            if(s.charAt(i)=='('||s.charAt(i)=='{'||s.charAt(i)=='['){
                a.add(s.charAt(i));
            }
            else{
                if(a.size()!=0){
                    if(s.charAt(i)==')'){
                        if(a.get(a.size()-1)=='('){
                            a.remove(a.size()-1);
                        }
                        else
                            return false;
                    }
                    if(s.charAt(i)=='}'){
                        if(a.get(a.size()-1)=='{'){
                            a.remove(a.size()-1);
                        }
                        else
                            return false;
                    }
                    if(s.charAt(i)==']'){
                        if(a.get(a.size()-1)=='['){
                            a.remove(a.size()-1);
                        }
                        else
                            return false;
                    }
                }
                else
                    return false;
            }

        }
        if(a.size()==0)
            return true;
        else
            return false;
    }
}

/*
You are given a large integer represented as an integer array digits, where each digits[i] is the ith digit of the integer. The digits are ordered from most significant to least significant in left-to-right order. The large integer does not contain any leading 0's.
Increment the large integer by one and return the resulting array of digits.

Example 1:
Input: digits = [1,2,3]
Output: [1,2,4]
Explanation: The array represents the integer 123.
Incrementing by one gives 123 + 1 = 124.
Thus, the result should be [1,2,4].

Example 2:
Input: digits = [4,3,2,1]
Output: [4,3,2,2]
Explanation: The array represents the integer 4321.
Incrementing by one gives 4321 + 1 = 4322.
Thus, the result should be [4,3,2,2].

Example 3:
Input: digits = [0]
Output: [1]
Explanation: The array represents the integer 0.
Incrementing by one gives 0 + 1 = 1.
Thus, the result should be [1].

Example 4:
Input: digits = [9]
Output: [1,0]
Explanation: The array represents the integer 9.
Incrementing by one gives 9 + 1 = 10.
Thus, the result should be [1,0].


Constraints:
1 <= digits.length <= 100
0 <= digits[i] <= 9
digits does not contain any leading 0's.
 */

public class PlusOneInArray {
    public static void main(String[] args){
        PlusOneInArray p = new PlusOneInArray();
        int[] input = {8,9,9,9};
        input = p.plusOne(input);
        System.out.print("[");
        for(int i=0;i<input.length;i++){
            System.out.print(input[i]);
            if(i!=input.length-1)
                System.out.print(",");
        }
        System.out.print("]");
    }
        public int[] plusOne(int[] digits) {
            int index=digits.length-1;
            int increment = 0;
            while(index>=0){
                if(digits[index]!=9){
                    if(increment==0)
                        digits[index]= digits[index]+1;
                    else
                        digits[index]= digits[index]+increment;
                    increment=0;
                    break;
                }
                else{
                    if(index==0){
                        increment=1;
                        digits[index]=0;
                        return addOne(digits);
                    }
                    else{
                        increment=1;
                        digits[index]=0;
                        index--;
                    }
                }
            }
            return digits;
        }

        public int[] addOne(int[] digits){
            int[] result = new int[digits.length+1];
            result[0] = 1;
            for(int i=0;i<digits.length;i++){
                result[i+1] = digits[i];
            }
            return result;
        }
}

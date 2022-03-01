/*
You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order,
and each of their nodes contains a single digit.
Add the two numbers and return the sum as a linked list.
You may assume the two numbers do not contain any leading zero, except the number 0 itself.

Example 1:
Input: l1 = [2,4,3], l2 = [5,6,4]
Output: [7,0,8]
Explanation: 342 + 465 = 807.

Example 2:
Input: l1 = [0], l2 = [0]
Output: [0]

Example 3:
Input: l1 = [9,9,9,9,9,9,9], l2 = [9,9,9,9]
Output: [8,9,9,9,0,0,0,1]

Constraints:
The number of nodes in each linked list is in the range [1, 100].
0 <= Node.val <= 9
It is guaranteed that the list represents a number that does not have leading zeros.
 */

public class AddTwoNumber {
    public static void main(String[] args){
        AddTwoNumber atn = new AddTwoNumber();
        ListNode input1 = new ListNode();
        ListNode input2 = new ListNode();
        input1.val = 2;
        input1.next = new ListNode(4);
        input1.next.next = new ListNode(3);
        input2.val = 5;
        input2.next = new ListNode(6);
        input2.next.next = new ListNode(4);
        ListNode result = atn.addTwoNumbers(input1,input2);
        while(result.next!=null){
            System.out.print(result.val);
            result = result.next;
        }
        System.out.println(result.val);
    }

    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
            boolean over = false;
            boolean l1F = false;
            boolean l2F = false;
            ListNode tl1 = l1;
            ListNode tl2 = l2;
            int first;
            int second;
            int fSize=0;
            int sSize=0;
            while(true){
                if(l1F)
                    first = 0;
                else
                    first = tl1.val;
                if(l2F)
                    second = 0;
                else
                    second = tl2.val;
                if((l1F && !l2F)||(over&&l1F&&l2F)){
                    ListNode temp = new ListNode();
                    temp.val = 0;
                    tl1.next = temp;
                    tl1=tl1.next;
                }
                if(over){
                    tl1.val = first + second +1;
                }
                else{
                    tl1.val = first + second;
                }
                over = false;
                if(tl1.val>=10){
                    tl1.val = tl1.val%10;
                    over = true;
                }
                if(!l1F && tl1.next==null)
                    l1F = true;
                if(!l2F && tl2.next==null)
                    l2F = true;
                if(!l1F){
                    tl1=tl1.next;
                    fSize++;
                }
                if(!l2F){
                    tl2=tl2.next;
                    sSize++;
                }
                if(l1F && l2F && !over){
                    break;
                }
            }
            return l1;
        }
}
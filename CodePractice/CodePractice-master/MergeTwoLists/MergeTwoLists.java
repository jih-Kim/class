/*
Merge two sorted linked lists and return it as a sorted list. The list should be made by splicing together the nodes of the first two lists.

Example 1:
Input: l1 = [1,2,4], l2 = [1,3,4]
Output: [1,1,2,3,4,4]

Example 2:
Input: l1 = [], l2 = []
Output: []

Example 3:
Input: l1 = [], l2 = [0]
Output: [0]


Constraints:
The number of nodes in both lists is in the range [0, 50].
-100 <= Node.val <= 100
Both l1 and l2 are sorted in non-decreasing order.
 */

public class MergeTwoLists {
    public static void main(String[] args){
        MergeTwoLists m = new MergeTwoLists();
        ListNode first = new ListNode(1);
        first.next = new ListNode(2);
        first.next.next = new ListNode(4);
        ListNode second = new ListNode(1);
        second.next = new ListNode(3);
        second.next.next = new ListNode(4);
        ListNode result = m.mergeTwoLists(first,second);
        System.out.print("[");
        while(result!=null){
            System.out.print(result.val);
            if(result.next!=null)
                System.out.print(",");
            result = result.next;
        }
        System.out.print("]");
    }
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
        ListNode result;
        if(l1==null){
            if(l2==null){
                return null;
            }
            else{
                return l2;
            }
        }
        if(l2==null){
            return l1;
        }
        if(l1.val<=l2.val){
            result = new ListNode(l1.val);
            l1=l1.next;
        }
        else{
            result = new ListNode(l2.val);
            l2=l2.next;
        }
        ListNode temp = result;
        while(l1!=null || l2!=null){
            if(l1==null){
                temp.next = l2;
                break;
            }
            if(l2==null){
                temp.next = l1;
                break;
            }
            if(l1.val<=l2.val){
                temp.next = new ListNode(l1.val);
                temp=temp.next;
                l1=l1.next;
            }
            else{
                temp.next=new ListNode(l2.val);
                temp = temp.next;
                l2=l2.next;
            }
        }
        return result;
    }
}

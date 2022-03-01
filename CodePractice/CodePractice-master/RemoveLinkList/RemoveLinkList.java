/*
Given the head of a linked list and an integer val, remove all the nodes of the linked list that has Node.val == val, and return the new head.
Example 1:
Input: head = [1,2,6,3,4,5,6], val = 6
Output: [1,2,3,4,5]

Example 2:
Input: head = [], val = 1
Output: []

Example 3:
Input: head = [7,7,7,7], val = 7
Output: []

Constraints:

The number of nodes in the list is in the range [0, 104].
1 <= Node.val <= 50
0 <= val <= 50
 */

public class RemoveLinkList {
    public static void main(String[] args){
        RemoveLinkList r = new RemoveLinkList();
        ListNode head = new ListNode(1);
        ListNode temp = head;
        temp.next = new ListNode(2);
        temp = temp.next;
        temp.next = new ListNode(6);
        temp = temp.next;
        temp.next = new ListNode(3);
        temp = temp.next;
        temp.next = new ListNode(4);
        temp = temp.next;
        temp.next = new ListNode(5);
        temp = temp.next;
        temp.next = new ListNode(6);
        ListNode result = r.removeElements(head,6);
        r.printNode(result);
    }

    public void printNode(ListNode head){
        ListNode temp = head;
        System.out.print("[");
        while(temp!=null){
            System.out.print(temp.val);
            if(temp.next!=null)
                System.out.print(",");
            temp = temp.next;
        }
        System.out.println("]");
    }

    public ListNode removeElements(ListNode head, int val) {
        if(head==null){
            return head;
        }
        ListNode prevTemp = head;
        ListNode temp = head.next;

        while(temp!=null){
            if(temp.val == val){
                prevTemp.next = temp.next;
                temp = temp.next;
            }
            else{
                prevTemp = temp;
                temp = temp.next;
            }
        }

        if(head.val==val){
            if(head.next!=null)
                head = head.next;
            else
                head = null;
        }

        return head;
    }

}
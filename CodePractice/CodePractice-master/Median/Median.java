/*
Given two sorted arrays nums1 and nums2 of size m and n respectively, return the median of the two sorted arrays.
The overall run time complexity should be O(log (m+n)).

Example 1:
Input: nums1 = [1,3], nums2 = [2]
Output: 2.00000
Explanation: merged array = [1,2,3] and median is 2.

Example 2:
Input: nums1 = [1,2], nums2 = [3,4]
Output: 2.50000
Explanation: merged array = [1,2,3,4] and median is (2 + 3) / 2 = 2.5.

Example 3:
Input: nums1 = [0,0], nums2 = [0,0]
Output: 0.00000

Example 4:
Input: nums1 = [], nums2 = [1]
Output: 1.00000

Example 5:
Input: nums1 = [2], nums2 = []
Output: 2.00000

Constraints:
nums1.length == m
nums2.length == n
0 <= m <= 1000
0 <= n <= 1000
1 <= m + n <= 2000
-106 <= nums1[i], nums2[i] <= 106
 */
public class Median {
    public static void main(String[] args){
        int[] input1 = {1,2};
        int[] input2 = {3,4};
        Median m = new Median();
        double result = m.findMedianSortedArrays(input1,input2);
        System.out.println(result);
    }
        public double findMedianSortedArrays(int[] nums1, int[] nums2) {
            int[] data = new int[nums1.length+nums2.length];
            int i=0;
            int j=0;
            int k=0;
            while(i!=nums1.length && j!=nums2.length){
                if(nums1[i]<nums2[j]){
                    data[k] = nums1[i];
                    i++;
                }
                else{
                    data[k] = nums2[j];
                    j++;
                }
                k++;
            }
            while(i!=nums1.length){
                data[k]=nums1[i];
                i++;
                k++;
            }
            while(j!=nums2.length){
                data[k]=nums2[j];
                j++;
                k++;
            }

            if(data.length%2==0){
                return (double)(data[data.length/2]+data[data.length/2-1])/2;
            }
            else
                return (double)data[data.length/2];
        }
}

import java.util.HashMap;
import java.util.Map;

/*
Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.
You may assume that each input would have exactly one solution, and you may not use the same element twice.
You can return the answer in any order.
Example 1:
Input: nums = [2,7,11,15], target = 9
Output: [0,1]
Output: Because nums[0] + nums[1] == 9, we return [0, 1].

Example 2:
Input: nums = [3,2,4], target = 6
Output: [1,2]

Example 3:
Input: nums = [3,3], target = 6
Output: [0,1]

Constraints:

2 <= nums.length <= 104
-109 <= nums[i] <= 109
-109 <= target <= 109
Only one valid answer exists.
 */


class Solution {
    public static void main(String[] args){
        int[] input = {2,7,11,15};
        int target = 9;
        Solution s = new Solution();
        int[] result = s.twoSum(input,target);
        System.out.print("[");
        for(int i=0;i<result.length;i++){
            if(i==result.length-1)
                System.out.print(result[i]);
            else
                System.out.print(result[i] + ", ");
        }
        System.out.println("]");
    }

    public int[] twoSum(int[] nums, int target) {
        Map<Integer,Integer> data = new HashMap<>();
        for(int i=0;i<nums.length;i++){
            if(data.containsKey(target-nums[i]) && data.get(target-nums[i])!=i){
                return new int[]{data.get(target-nums[i]),i};
            }
            data.put(nums[i],i);
        }
        throw new IllegalArgumentException("No two sum solution");
    }


}


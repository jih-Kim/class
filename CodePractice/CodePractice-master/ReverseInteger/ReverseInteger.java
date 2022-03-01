import java.lang.Math;
public class ReverseInteger {
    public static void main(String[] args){
        ReverseInteger r = new ReverseInteger();
        int input = 123;
        int result = r.reverse(input);
        System.out.println(result);
    }

    public int reverse(int x) {
            boolean minus = false;
            if (x < 0) {
                minus = true;
                x = 0 - x;
            }
            if (x < Integer.MIN_VALUE || x > Integer.MAX_VALUE)
                return 0;
            int result = 0;
            while (x != 0) {
                result = result * 10;
                if (result % 10 != 0)
                    return 0;
                result = result + x % 10;
                x = x / 10;
            }
            if (minus)
                result = 0 - result;
            return result;
        }
}

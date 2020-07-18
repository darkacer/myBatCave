public class peopleInCircle {

    static int calc(int b1, int b2, int n) {
        int abs = (b1 < b2) ? (b2 - b1) : (b1 - b2);
        return (n - abs < abs) ? n - abs : abs;
    }

    static int calc2(int b1, int b2, int n) {
        return (n - ((b1 < b2) ? (b2 - b1) : (b1 - b2)) < ((b1 < b2) ? (b2 - b1) : (b1 - b2))) ? n - ((b1 < b2) ? (b2 - b1) : (b1 - b2)) : ((b1 < b2) ? (b2 - b1) : (b1 - b2));
    }

    public static void main(String[] args) {
        System.out.println(calc2(5, 5, 5));
        System.out.println(calc2(1, 5, 5));
        System.out.println(calc2(1, 4, 5));
    }
}
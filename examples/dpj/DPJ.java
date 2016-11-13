import DPJRuntime.*;

public class IntegerSumReduction {
    private region AccumRgn;
    private static int sum in AccumRgn;
    public static <region R | R:* # AccumRgn> int
      reduce(DPJArrayInt<R> arr, int tileSize)
        reads R:* writes AccumRgn {
        sum = 0;
        DPJPartitionInt<R> segs =
            DPJPartitionInt.<region R>
            stridedPartition(arr, tileSize);
        foreach(int i in 0, segs.length) {
            int partialSum = 0;
            DPJArrayInt<R:*> seg = segs.get(i);
            for (int j = 0; j < seg.length; ++j)
                partialSum += seg.get(j);
            updateSum(partialSum);
        }
        return sum;
    }
    private static commutative synchronized
        void updateSum(int partialSum) writes AccumRgn {
            sum += partialSum;
    }
    public static void main(String[] args) {
        region MainRgn;
        int SIZE = 1000000;
        int TILESIZE = 1000;
        DPJArrayInt<MainRgn> arr =
            new DPJArrayInt<MainRgn>(SIZE);
        arr.put(42, 42);
        int sum = reduce(arr, TILESIZE);
        System.out.println("sum="+sum);
    }
}


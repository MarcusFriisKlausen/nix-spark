import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.TaskContext;
import org.apache.spark.SparkEnv;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class SparkClusterIntegrationTest {
    public static void main(String[] args) {
        // Initialize SparkSession
        SparkSession spark = SparkSession.builder()
                .appName("SparkClusterIntegrationTest")
                .getOrCreate();

        JavaSparkContext sc = new JavaSparkContext(spark.sparkContext());

        int numPartitions = 4;

        List<Integer> data = IntStream.rangeClosed(1, 100000)
                                      .boxed()
                                      .collect(Collectors.toList());
 
        JavaRDD<Integer> rdd = sc.parallelize(data, numPartitions);

        JavaRDD<Long> squaredRdd = rdd.map(x -> (long) x * x);

        long totalSum = squaredRdd.reduce(Long::sum);

        System.out.println("Total sum of squares: " + totalSum);

        List<String> partitionInfo = rdd.mapPartitionsWithIndex((index, iter) -> {
            TaskContext tc = TaskContext.get();
            int count = 0;
            while (iter.hasNext()) { iter.next(); count++; }

            long taskId = tc.taskAttemptId();
            int cpus = tc.cpus();
            String host = java.net.InetAddress.getLocalHost().getHostName();

            return java.util.Collections.singletonList(
                String.format(
                    "Partition %d : %d elements | taskId=%d | cpus=%d | host=%s",
                    index, count, taskId, cpus, host
                )
            ).iterator();
        }, true).collect();

        for (String info : partitionInfo) {
            System.out.println(info);
        }

        spark.stop();
    }
}

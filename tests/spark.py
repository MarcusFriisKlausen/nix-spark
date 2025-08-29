from pyspark.sql import SparkSession
from pyspark import TaskContext

# Initialize Spark
spark = SparkSession.builder \
    .appName("SparkClusterDistributionTest") \
    .config("spark.driver.host", "192.168.123.101") \
    .config("spark.driver.port", "7079") \
    .getOrCreate()

sc = spark.sparkContext

# Generate some data and split into multiple partitions
num_partitions = 4
data = list(range(1, 101))  # small dataset for demo
rdd = sc.parallelize(data, num_partitions)

# Function to inspect partition and executor
def partition_info(idx, iterator):
    executor_id = TaskContext.get().executorId()  # Get the executor processing this partition
    worker_host = TaskContext.get().hostname()   # Get the worker host
    elements = list(iterator)
    yield {
        "partition_id": idx,
        "executor_id": executor_id,
        "worker_host": worker_host,
        "num_elements": len(elements),
        "sample_elements": elements[:5]  # show first 5 for brevity
    }

# Apply function to each partition
partitions_data = rdd.mapPartitionsWithIndex(partition_info).collect()

# Print results
print("Partition distribution across cluster:")
for info in partitions_data:
    print(f"Partition {info['partition_id']} processed by executor {info['executor_id']} "
          f"on worker {info['worker_host']}, {info['num_elements']} elements, sample: {info['sample_elements']}")

# Perform a simple distributed computation
total_sum = rdd.map(lambda x: x**2).reduce(lambda a, b: a + b)
print(f"\nTotal sum of squares: {total_sum}")

# Stop Spark
spark.stop()

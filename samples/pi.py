import sys
from random import random
from operator import add

from pyspark.sql import SparkSession

def inside(p):
    x, y = random.random(), random.random()
    return x*x + y*y < 1


if __name__ == "__main__":
    """
        Usage: pi [partitions]
    """
    spark = SparkSession\
        .builder\
        .appName("PythonPi")\
        .getOrCreate()

    n = 100000 * 2

    def f(_):
        x = random() * 2 - 1
        y = random() * 2 - 1
        return 1 if x ** 2 + y ** 2 <= 1 else 0

    count = spark.sparkContext.parallelize(range(1, n + 1), 30).map(f).reduce(add)
    print("Pi is roughly %f" % (4.0 * count / n))

    spark.stop()
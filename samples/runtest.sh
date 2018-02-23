#!/bin/sh

set -o errexit





DRIVER_APP_TYPE="jar"
MAIN_CLASS="SampleSparkJob"
SPARK_MASTER_URL="spark://jdediego-Precision-T5610:7077"
SPARK_DRIVER_HOST="jdediego-Precision-T5610"
SPARK_DRIVER_PORT="7077"
SPARK_UI_PORT="4040"
SPARK_BLOCKMGR_PORT="1024"
SPARK_CONF="--conf spark.executor.memory=2g --conf spark.driver.cores=2"
REMOTE_JAR_FILE="Sample-Spark-Project/target/scala-2.10/sample-spark-project-assembly-1.0.jar" 


  echo "Handling JAR file $REMOTE_JAR_FILE"
  echo "Application main class: $MAIN_CLASS"
  echo "Application arguments: $APP_ARGS"
  echo "Spark master: $SPARK_MASTER_URL"
  echo "Spark driver host: $SPARK_DRIVER_HOST"
  echo "Spark driver port: $SPARK_DRIVER_PORT"
  echo "Spark UI port: $SPARK_UI_PORT"
  echo "Spark block manager port: $SPARK_BLOCKMGR_PORT"
  echo "Spark configuration settings: $SPARK_CONF"


  spark-submit \
    --master "$SPARK_MASTER_URL" \
    --conf spark.driver.bindAddress="172.26.0.1" \
    --conf spark.driver.host="172.26.0.1" \
    --conf spark.driver.port=$SPARK_DRIVER_PORT \
    --conf spark.ui.port=$SPARK_UI_PORT \
    --conf spark.blockManager.port=$SPARK_BLOCKMGR_PORT \
    $SPARK_CONF \
    --class "$MAIN_CLASS" \
    "$REMOTE_JAR_FILE" \
    $APP_ARGS  










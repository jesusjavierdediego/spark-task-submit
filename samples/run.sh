
#!/bin/sh

set -o nounset
set -o errexit

ip_addr="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]+\.){3}[0-9]+' | grep -Eo '([0-9]+\.){3}[0-9]+' | grep -v '127.0.0.1' | grep -v '172.17.0.1')"
if test -z "$ip_addr"
then
  echo "Cannot determine the machine IP address."
  exit 1
fi

DRIVER_APP_TYPE="jar"
MAIN_CLASS="SampleSparkJob"
SPARK_MASTER_URL="spark://192.168.1.8:7077"
SPARK_DRIVER_HOST="192.168.1.8"
SPARK_DRIVER_PORT="7077"
SPARK_UI_PORT="4040"
SPARK_BLOCKMGR_PORT="1024"
SPARK_CONF="--conf spark.executor.memory=2g --conf spark.driver.cores=2"
REMOTE_JAR_FILE="sample-spark-project-assembly-1.0.jar" 
APP_ARGS=""


  echo "Handling JAR file $REMOTE_JAR_FILE"
  echo "Application main class: $MAIN_CLASS"
  echo "Spark master: $SPARK_MASTER_URL"
  echo "Spark driver host: $SPARK_DRIVER_HOST"
  echo "Spark driver port: $SPARK_DRIVER_PORT"
  echo "Spark UI port: $SPARK_UI_PORT"
  echo "Spark block manager port: $SPARK_BLOCKMGR_PORT"
  echo "Spark configuration settings: $SPARK_CONF"


 spark-submit \
    --master "$SPARK_MASTER_URL" \
    --conf spark.driver.bindAddress="$ip_addr" \
    --conf spark.driver.host="$SPARK_DRIVER_HOST" \
    --conf spark.driver.port=$SPARK_DRIVER_PORT \
    --conf spark.ui.port=$SPARK_UI_PORT \
    --conf spark.blockManager.port=$SPARK_BLOCKMGR_PORT \
    $SPARK_CONF \
    --class "$MAIN_CLASS" \
    "$REMOTE_JAR_FILE" \
$APP_ARGS 


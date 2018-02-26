#!/bin/sh

set -o errexit


test -z "$DRIVER_APP_TYPE" && ( echo "DRIVER_APP_TYPE is not set; exiting" ; exit 1 )
test -z "$SCM_URL" && ( echo "SCM_URL is not set; exiting" ; exit 1 )
test -z "$SPARK_MASTER_URL" && ( echo "SPARK_MASTER_URL is not set; exiting" ; exit 1 )
test -z "$SPARK_BLOCKMGR_PORT" && ( echo "SPARK_BLOCKMGR_PORT is not set; exiting" ; exit 1 )

echo "STEP: Get the container internal IP (spark.driver.bindAddress)"
ip_addr="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]+\.){3}[0-9]+' | grep -Eo '([0-9]+\.){3}[0-9]+' | grep -v '127.0.0.1' | head)"
if test -z "$ip_addr"
then
  echo "Cannot determine the container IP address."
  exit 1
else
  echo "The container IP address is $ip_addr. It will be set as spark.driver.bindAddress"
fi

SPARK_DRIVER_PORT="7077"
SPARK_UI_PORT="4040"

if [ "$DRIVER_APP_TYPE" = "scala" ] || [ "$DRIVER_APP_TYPE" = "python" ]
then
  echo "STEP: Cloning the repository of the driver application: $SCM_URL"
  git clone "$SCM_URL"
  project_git="${SCM_URL##*/}"
  project_dir="${project_git%.git}"
  if test -n "$SCM_BRANCH"
  then
    cd "$project_dir"
    git checkout "$SCM_BRANCH"
    cd -
  fi

elif [ "$DRIVER_APP_TYPE" = "jar" ]
then
  echo "---------- MODE: JAR ----------"
  echo "STEP: Downloading JAR file of the driver application: $REMOTE_JAR_FILE"
  
  remoteJarFile=$(basename "$REMOTE_JAR_FILE")
  wget $REMOTE_JAR_FILE

  echo "----------Driver application information----------"
  echo "Handling JAR file $remoteJarFile"
  echo "Application main class: $MAIN_CLASS"
  echo "Application arguments: $APP_ARGS"
  echo "Spark master: $SPARK_MASTER_URL"
  echo "Spark bind address: $ip_addr"
  echo "Spark driver host: $SPARK_DRIVER_HOST"
  echo "Spark driver port: $SPARK_DRIVER_PORT"
  echo "Spark UI port: $SPARK_UI_PORT"
  echo "Spark block manager port: $SPARK_BLOCKMGR_PORT"
  echo "Spark configuration settings: $SPARK_CONF"
 echo "---------------------------------------------------"

  spark-submit \
    --master "$SPARK_MASTER_URL" \
    --conf spark.driver.bindAddress="$ip_addr" \
    --conf spark.driver.host="$SPARK_DRIVER_HOST" \
    --conf spark.driver.port=$SPARK_DRIVER_PORT \
    --conf spark.ui.port=$SPARK_UI_PORT \
    --conf spark.blockManager.port=$SPARK_BLOCKMGR_PORT \
    $SPARK_CONF \
    --class "$MAIN_CLASS" \
    "$remoteJarFile" \
    $APP_ARGS  
fi

if [ "$DRIVER_APP_TYPE" = "scala" ]
then
  echo "---------- MODE: Scala ----------"
  echo "STEP: Start building the jar"
  if test -z "$PROJECT_SUBDIR"
  then
    cd "$project_dir"
  else
    cd "$project_dir/$PROJECT_SUBDIR"
  fi
  echo "STEP: Building at: $(pwd)"

  test -z "$MAIN_CLASS" && ( echo "MAIN_CLASS is not set; exiting" ; exit 1 )
  if test -z "$BUILD_COMMAND"
  then
    build_command="sbt 'set test in assembly := {}' clean assembly"
  else
    build_command="$BUILD_COMMAND"
  fi
  echo "STEP: Building with command: $build_command"
  eval $build_command

  if test -z "$JAR_FILE"
  then
    jarfile="$(ls target/scala-*/*.jar)"
  else
    jarfile="$JAR_FILE"
  fi
  if ! test -f "$jarfile"
  then
    echo "ERROR: Jar file not found or not a single file: $jarfile"
    echo "You can specify jar file explicitly: -e JAR_FILE=/path/to/file"
    exit 1
  fi

  echo "----------Driver application information----------"
  echo "Handling Scala application"
  echo "Submitting JAR file: $jarfile"
  echo "Application main class: $MAIN_CLASS"
  echo "Application arguments: $APP_ARGS"
  echo "Spark master: $SPARK_MASTER_URL"
  echo "Spark driver host: $SPARK_DRIVER_HOST"
  echo "Spark driver port: $SPARK_DRIVER_PORT"
  echo "Spark UI port: $SPARK_UI_PORT"
  echo "Spark block manager port: $SPARK_BLOCKMGR_PORT"
  echo "Spark configuration settings: $SPARK_CONF"
 echo "---------------------------------------------------"


  spark-submit \
    --master "$SPARK_MASTER_URL" \
    --conf spark.driver.bindAddress="$ip_addr" \
    --conf spark.driver.host="$SPARK_DRIVER_HOST" \
    --conf spark.driver.port=$SPARK_DRIVER_PORT \
    --conf spark.ui.port=$SPARK_UI_PORT \
    --conf spark.blockManager.port=$SPARK_BLOCKMGR_PORT \
    $SPARK_CONF \
    --class "$MAIN_CLASS" \
    "$jarfile" \
    $APP_ARGS

elif [ "$DRIVER_APP_TYPE" = "python" ]
then
  echo "---------- MODE: Python ----------"
  if test -z "$PYTHON_FILE"
  then
    pythonfile="$project_dir/main.py"
  else
    pythonfile="$PYTHON_FILE"
  fi
  if ! test -f "$pythonfile"
  then
    echo "ERROR: Python file not found or not a single file: $pythonfile"
    echo "You can specify a python file explicitly: -e PYTHON_FILE=/path/to/file"
    exit 1
  fi

  echo "----------Driver application information----------"
  echo "Submitting python script: $pythonfile"
  echo "Application arguments: $APP_ARGS"
  echo "Spark master: $SPARK_MASTER_URL"
  echo "Spark driver host: $SPARK_DRIVER_HOST"
  echo "Spark driver port: $SPARK_DRIVER_PORT"
  echo "Spark UI port: $SPARK_UI_PORT"
  echo "Spark block manager port: $SPARK_BLOCKMGR_PORT"
  echo "Spark configuration settings: $SPARK_CONF"
  echo "---------------------------------------------------"

spark-submit \
    --master "$SPARK_MASTER_URL" \
    --conf spark.driver.bindAddress="$ip_addr" \
    --conf spark.driver.host="$SPARK_DRIVER_HOST" \
    --conf spark.driver.port=$SPARK_DRIVER_PORT \
    --conf spark.ui.port=$SPARK_UI_PORT \
    --conf spark.blockManager.port=$SPARK_BLOCKMGR_PORT \
    $SPARK_CONF \
    $PYTHON_FILE \ 
    $APP_ARGS
else
  echo "ERROR: Not recognized type of application (DRIVER_APP_TYPE): scala|jar|python."
fi











#!/bin/sh

set -o nounset
set -o errexit

spark_host="10.120.16.57"
spark_port="7077"

docker run \
  -ti \
  --rm \
  -p 5000-5010:5000-5010 \
  --name spark-submit \
  --net host \
  -v ~/data:/data \
  -e SCM_URL="https://github.com/tashoyan/sc.git" \
  -e SCM_BRANCH="spark" \
  -e PROJECT_SUBDIR="05-functional-programming-in-scala-capstone/observatory" \
  -e SPARK_MASTER_URL="spark://$spark_host:$spark_port" \
  -e MAIN_CLASS="image.Generator0S" \
  -e DRIVER_APP_TYPE="scala" \
  -e SPARK_DRIVER_HOST="$spark_host" \
  -e SPARK_DRIVER_PORT="$spark_port" \
     sparksubmit:latest

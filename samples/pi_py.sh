#!/bin/sh

set -o nounset
set -o errexit

ip_addr="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]+\.){3}[0-9]+' | grep -Eo '([0-9]+\.){3}[0-9]+' | grep -v '127.0.0.1' | grep -v '172.17.0.1')"
if test -z "$ip_addr"
then
  echo "Cannot determine the machine IP address."
  exit 1
fi

docker run \
  -ti \
  --rm \
  -p 5000-5010:5000-5010 \
  --name spark-submit \
  -v ~/data:/data \
  -e SCM_URL="" \
  -e SPARK_MASTER_URL="spark://$ip_addr:7077" \
  -e PYTHON_FILE="pi.py" \
  -e DRIVER_APP_TYPE="python" \
  -e SPARK_DRIVER_HOST="$ip_addr" \
     sparksubmit:latest

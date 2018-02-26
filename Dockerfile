FROM openjdk:8u151

# CONSTANTS
ENV SCALA_VERSION 2.12.4
ENV SBT_VERSION 1.1.1
ENV SPARK_VERSION 2.2.1

RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

RUN apt-get update && \
    apt-get install -y net-tools

# 1-Install Scala
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc


# 2-Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion


# 3-Install Spark
ENV SPARK_PACKAGE spark-$SPARK_VERSION-bin-hadoop2.7
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl --silent \
         --show-error \
         --location \
         --retry 3 \
        "http://www-eu.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.7.tgz" | \
    tar -xz -C /usr/ && \
    mv /usr/$SPARK_PACKAGE $SPARK_HOME && \
chmod -R 7777 $SPARK_HOME

ENV PATH $PATH:$SBT_HOME/bin:$SPARK_HOME/bin
ENV SPARK_MASTER local[*]
ENV SPARK_DRIVER_PORT 5001
ENV SPARK_UI_PORT 5002
ENV SPARK_BLOCKMGR_PORT 5003
EXPOSE $SPARK_DRIVER_PORT $SPARK_UI_PORT $SPARK_BLOCKMGR_PORT

WORKDIR /root

COPY run.sh /
RUN chmod +x /run.sh
CMD /run.sh


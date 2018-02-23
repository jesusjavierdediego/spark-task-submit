# Spark Task Submit
## Docker image to run applications/scripts against a Spark cluster

Performs the following tasks:
1. Gets the source code from the SCM repository (scala and python modes). Alternatively retrieves the jar file ('jar' mode).
1. Builds the application ('scala' mode)
1. Runs the application/script by submitting it to the Spark cluster

For the moment, it is supported:

1. SCM: Git
1. Builder: SBT (Scala)
1. Script: Python
1. JAR files (Java/Scala)

Coming soon:

1. Builder: Maven, Gradle
1. Script: R

Everything is integrated as commands present in the PATH within the image.

Only three types of tasks are enabled for now:

1. Scala ('scala' mode)
1. JVM languages ('jar' mode)
1. Python ('python' mode)

We need to pass this value for the argument DRIVER_APP_TYPE



Run Scala example:
```
docker run \
  -ti \
  --rm \
  -p 5000-5010:5000-5010 \
  -e SCM_URL="https://github.com/scala/project.git" \
  -e SPARK_MASTER_URL="spark://my.master.com:7077" \
  -e MAIN_CLASS="Main" \
  -e DRIVER_APP_TYPE="scala" \
  <registry>/sparksubmit:latest
```
Run Python example:
```
docker run \
  -ti \
  --rm \
  -p 5000-5010:5000-5010 \
  -e SCM_URL="https://github.com/python/project.git" \
  -e SPARK_MASTER_URL="spark://my.master.com:7077" \
  -e PYTHON_FILE="pi.py" \
  -e DRIVER_APP_TYPE="python" \
  <registry>/sparksubmit:latest
```

## Working with data

If our Spark program requires some data for processing, you can add the data to the container by specifying a volume (e.g. -v /data:/data):

```
docker run \
  -ti \
  --rm \
  -v /data:/data \
  -p 5000-5010:5000-5010 \
  -e SCM_URL="https://github.com/mylogin/project.git" \
  -e SPARK_MASTER_URL="spark://my.master.com:7077" \
  -e MAIN_CLASS="Main" \
  -e DRIVER_APP_TYPE="scala" \
  <registry>/sparksubmit:latest
```


## Important command line arguments

`-p 5000-5010:5000-5010`

We have to publish this range of network ports. Spark driver program and Spark executors use these ports for communication.

`-e SPARK_DRIVER_HOST="host.machine.address"`

We need to specify here the network address of the host where the container is running. This is necessary for communication between executors and the driver program.
For detailed technical information see [SPARK-4563](https://issues.apache.org/jira/browse/SPARK-4563).

## Command line arguments

Command line arguments are passed via environment variables for `docker` command: `-e VAR="value"`. Here is the full list:

| Name | Mandatory? | Meaning | Default value |
| ---- |:----------:| ------- | ------------- |
| SCM_URL | Yes | URL to get source code from. | N/A |
| SCM_BRANCH | No | SCM branch to checkout. | master |
| PROJECT_SUBDIR | No | A relative directory to the root of the SCM working copy.<br>If specified, then the build will be executed in this directory, rather than in the root directory. | N/A |
| BUILD_COMMAND | No | Command to build the application. | `sbt 'set test in assembly := {}' clean assembly`<br>Means: build fat-jar using sbt-assembly plugin skipping the tests. |
| SPARK_MASTER_URL | No | Spark master URL inlcuding spark protcol and port. | For instance, `spark://my.master.com:7077` |
| SPARK_CONF | No | Arbitrary Spark configuration settings, like:<br>`--conf spark.executor.memory=2g --conf spark.driver.cores=2` | Empty |
| SPARK_DRIVER_HOST | Yes | Value of the `spark.driver.host` configuration parameter.<br>Must be set to the network address of the machine hosting the container. Must be accessible from Spark nodes. | N/A |
| JAR_FILE | No | Path to the application jar file. Relative to the build directory.<br> If not specified, the jar file will be automatically found under `target/` subdirectory of the build directory. | N/A |
| APP_ARGS | No | Application arguments. | Empty |
| DRIVER_APP_TYPE | Yes | Mode for the submission (scala|jar|python). | N/A |
| REMOTE_JAR_FILE | No | 'jar' mode only. URL to the remote application jar file in an artifact repository. | N/A |
| MAIN_CLASS | Yes | 'scala' and 'jar' modes only. Main class of the application to run. Choose 'scala' as the DRIVER_APP_TYPE value. | N/A |
| PYTHON_FILE | Yes | 'python' mode only. Main file of the application to run. Choose 'python' as the DRIVER_APP_TYPE value. | N/A |
| http_proxy, https_proxy | No | Specify when running behind a proxy. | Empty, no proxy |


## Available image tags

Supported Spark versions:
* spark-2.2.1

## Related images

sparksubmit:latest


## Building the image

Build the image:
```
docker build \
  -t <registry>/sparksubmit:latest \
  -f Dockerfile \
  .
```
When building on a machine behind proxy, specify `http_proxy` environment variable:
```
docker build \
  --build-arg http_proxy=http://my.proxy.com:8080 \
  -t <registry>/sparksubmit:latest \
  -f Dockerfile \
  .
```

## Understand the parameters

### Scala project example

Git project cloned and then built. Specific Spark configuration. The sbt command can change. Recommended: sbt assembly.

```
DRIVER_APP_TYPE="scala"
SCM_URL="https://github.com/jesusjavierdediego/Sample-Spark-Project.git"
SCM_BRANCH="master"
MAIN_CLASS="SampleSparkJob"
SPARK_MASTER_URL="spark://masterhost:7077"
SPARK_DRIVER_HOST="$ip_addr"
SPARK_DRIVER_PORT="7077"
SPARK_UI_PORT="4040"
SPARK_BLOCKMGR_PORT="1024"
SPARK_CONF="--conf spark.executor.memory=2g --conf spark.driver.cores=2"
# Alternative: "sbt clean package"
BUILD_COMMAND="sbt assembly"
#depending on the project we can need to specify the relative location of the generated JAR file
JAR_FILE="target/scala-2.10/sample-spark-project-assembly-1.0.jar" 
```

### JVM project example.  

JAR file (pre-built). Specific Spark configuration. The sbt command can change. Recommended: sbt assembly.

```
DRIVER_APP_TYPE="jar"
# Include a full URL in an available artifact repository
REMOTE_JAR_FILE="http://artifactory-citp.fexcosoftware.com/artifactory/libs-release-local/com/fexco/bureau/bigdata-timeusage_2.11/0.1-SNAPSHOT/bigdata-timeusage_2.11-0.1-SNAPSHOT.jar" \
MAIN_CLASS="SampleSparkJob"
SPARK_MASTER_URL="spark://masterhost:7077"
SPARK_DRIVER_HOST="$ip_addr"
SPARK_DRIVER_PORT="7077"
SPARK_UI_PORT="4040"
SPARK_BLOCKMGR_PORT="1024"
SPARK_CONF="--conf spark.executor.memory=2g --conf spark.driver.cores=2"
```


#### Python project example

Git project cloned. Specific Spark configuration. Script languages do not need build process. 

```
DRIVER_APP_TYPE="python"
SCM_URL="https://github.com/jesusjavierdediego/Sample-Spark-Project.git"
PYTHON_FILE="python/newpi.py"
SPARK_MASTER_URL="spark://masterhost:7077"
SPARK_MASTER_PORT="7077"
SPARK_DRIVER_HOST="$ip_addr"
SPARK_DRIVER_PORT="7077"
SPARK_UI_PORT="4040"
SPARK_BLOCKMGR_PORT="1024"
SPARK_CONF="--conf spark.executor.memory=2g --conf spark.driver.cores=2"
```

## License

Apache 2.0 license.

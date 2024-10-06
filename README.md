# spark-docker
Spark standalone cluster with docker compose


1. Build locally the docker image
```
docker build -t cluster-apache-spark:3.5.3 .
```

2. Deploy the Spark Standalone cluster
```
docker-compose up -d
```

3. Verify spark cluster is up and running

## List docker running containers
```
docker ps -a
```

You should get a similar output like this:

```
CONTAINER ID   IMAGE                        COMMAND                  CREATED          STATUS          PORTS                                                      NAMES
6bddbd3b5cfa   cluster-apache-spark:3.5.3   "/bin/bash /start-sp…"   11 minutes ago   Up 11 minutes   7077/tcp, 0.0.0.0:7001->7000/tcp, 0.0.0.0:9091->8080/tcp   spark-docker-spark-worker-a-1
4195b53e7543   cluster-apache-spark:3.5.3   "/bin/bash /start-sp…"   15 minutes ago   Up 15 minutes   7000/tcp, 0.0.0.0:7077->7077/tcp, 0.0.0.0:9090->8080/tcp   spark-docker-spark-master-1
```

## Container exposed ports


container|Exposed ports
---|---
spark-master|9090 7077
spark-worker-1|9091


### Spark Master

http://localhost:9090/


### Spark Worker 1

http://localhost:9091/


## Create a Spark Session from python using PySpark

Create a `.py` file with the following content and run it:

```python
from pyspark.sql import SparkSession

# Create a SparkSession
spark = SparkSession.builder \
    .appName("MySparkApplication") \
    .master("spark://localhost:7077") \
    .getOrCreate()
```


```python
# Print Spark session details
print("Spark Application Name:", spark.sparkContext.appName)
print("Spark Master URL:", spark.sparkContext.master)
print("Spark Version:", spark.version)
print("Spark Application ID:", spark.sparkContext.applicationId)
print("Spark Web UI URL:", spark.sparkContext.uiWebUrl)
print("Spark User:", spark.sparkContext.sparkUser())
print("Spark Configurations:")
for key, value in spark.sparkContext.getConf().getAll():
    print(f"  {key}: {value}")
```

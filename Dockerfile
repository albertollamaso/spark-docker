FROM openjdk:11.0.16-jre-slim-buster AS builder

# Add Dependencies for PySpark
RUN apt-get update && apt-get install -y curl wget gcc make vim software-properties-common ssh net-tools ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev

RUN wget https://www.python.org/ftp/python/3.11.10/Python-3.11.10.tgz && \
	tar -xf Python-3.11.10.tgz && \
	cd Python-3.11.10 && \
	./configure --enable-optimizations && \
	make -j$(nproc) && \
	make altinstall && \
	cd .. && rm -rf Python-3.11.10 Python-3.11.10.tgz

# Step 3: Set Python 3.11 as default
RUN rm -rf /usr/bin/python3
RUN ln -s /usr/local/bin/python3.11 /usr/bin/python3

# Verify installation
RUN python3 --version

RUN apt-get update && apt-get install -y python3-pip python3-numpy python3-matplotlib python3-scipy python3-pandas python3-simpy
RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV SPARK_VERSION=3.5.3 \
	HADOOP_VERSION=3 \
	SPARK_HOME=/opt/spark \
	PYTHONHASHSEED=1

RUN wget --no-verbose -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
	&& mkdir -p /opt/spark \
	&& tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
	&& rm apache-spark.tgz

RUN apt update \
	&& pip3 install pyspark


FROM builder AS apache-spark

WORKDIR /opt/spark

ENV SPARK_MASTER_PORT=7077 \
	SPARK_MASTER_WEBUI_PORT=8080 \
	SPARK_LOG_DIR=/opt/spark/logs \
	SPARK_MASTER_LOG=/opt/spark/logs/spark-master.out \
	SPARK_WORKER_LOG=/opt/spark/logs/spark-worker.out \
	SPARK_WORKER_WEBUI_PORT=8080 \
	SPARK_WORKER_PORT=7000 \
	SPARK_MASTER="spark://spark-master:7077" \
	SPARK_WORKLOAD="master"

EXPOSE 8080 7077 7000

RUN mkdir -p $SPARK_LOG_DIR && \
	touch $SPARK_MASTER_LOG && \
	touch $SPARK_WORKER_LOG && \
	ln -sf /dev/stdout $SPARK_MASTER_LOG && \
	ln -sf /dev/stdout $SPARK_WORKER_LOG

COPY start-spark.sh /

CMD ["/bin/bash", "/start-spark.sh"]

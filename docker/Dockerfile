# Take reference From:
#   https://github.com/apache/spark-docker
#   3.5.0/scala2.12-java11-ubuntu/Dockerfile
#
#  https://hub.docker.com/_/eclipse-temurin/tags?page=1&name=11-jre-focal
#
#  NB: Got jdbc issue with FROM eclipse-temurin:8u402-b06-jre-alpine
#
FROM eclipse-temurin:11-jre-focal
#FROM eclipse-temurin:8-jre-noble

ARG ARG_HADOOP_VERSION=3.2.0
ARG ARG_METASTORE_VERSION=3.1.3
ARG ARG_JDBC_VERSION=42.7.3
ARG MYSQL_CONNECTOR_VERSION=8.0.25
ARG LOG4J_SCANNER_VERSION=2.9.1
ARG JMX_PROMETHEUS_JAVAAGENT_VERSION=1.0.1
ARG JMX_PORT=9025

ENV HADOOP_VERSION=$ARG_HADOOP_VERSION
ENV METASTORE_VERSION=$ARG_METASTORE_VERSION
ENV JDBC_VERSION=$ARG_JDBC_VERSION
ENV MYSQL_CLIENT_VERSION="8.0.42-0ubuntu0.20.04.1"

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-client \
    sudo \
    mysql-client=${MYSQL_CLIENT_VERSION} && \
    apt-get clean -y

WORKDIR /opt

RUN curl -L https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar xvzf -

# dlcdn.apache.org is faster, but does not provide 3.2.0 version. So fallback on archive.apache.org
#RUN curl -L https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
#    rm -f hadoop-${HADOOP_VERSION}/share/hadoop/common/lib/slf4j-log4j12-*.jar

RUN curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    rm -f hadoop-${HADOOP_VERSION}/share/hadoop/common/lib/slf4j-log4j12-*.jar

RUN curl -L https://jdbc.postgresql.org/download/postgresql-${JDBC_VERSION}.jar -o /opt/apache-hive-metastore-${METASTORE_VERSION}-bin/lib/postgresql-${JDBC_VERSION}.jar

# download and install mysql-connector-java
RUN curl -sLO "https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar" --output mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar \
    && mv mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar ${HIVE_HOME}/lib/

# download the log4shell scanner and run it on different paths
RUN curl -sLO "https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/${LOG4J_SCANNER_VERSION}/log4j-core-${LOG4J_SCANNER_VERSION}.jar" \

    && java -jar log4j-core-${LOG4J_SCANNER_VERSION}.jar --scan-log4j1 --scan-zip --scan-logback --force-fix /usr/lib || true \
    && java -jar log4j-core-${LOG4J_SCANNER_VERSION}.jar --scan-log4j1 --scan-zip --scan-logback --force-fix /var/lib || true \
    && java -jar log4j-core-${LOG4J_SCANNER_VERSION}.jar --scan-log4j1 --scan-zip --scan-logback --force-fix /opt || true \
    && rm log4j-core-${LOG4J_SCANNER_VERSION}.jar

# add the Prometheus JMX exporter Java agent jar for exposing metrics
RUN curl -sLO "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_PROMETHEUS_JAVAAGENT_VERSION}/jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar" \

    && mkdir /prometheus \
    && mv jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar /prometheus/ \
    && chmod 644 /prometheus/jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar

COPY config.yaml /prometheus

COPY docker/metastore.sh /metastore.sh

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive -R /prometheus  && \
    chown hive:hive /metastore.sh && chmod +x /metastore.sh

# Security breach, but must be in a namespace with relaxed psp to be able to sudo
COPY docker/hive.sudoer /etc/sudoers.d/hive

USER 1000

ENV HADOOP_OPTS="$HADOOP_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9026 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -javaagent:/prometheus/jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar=${JMX_PORT}:/prometheus/config.yaml"

EXPOSE 9083
EXPOSE ${JMX_PORT}

ENTRYPOINT ["sh", "-c", "/metastore.sh"]
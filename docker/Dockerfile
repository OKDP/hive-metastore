FROM eclipse-temurin:17-jre-noble

ARG ARG_HADOOP_VERSION=3.3.6
ARG ARG_METASTORE_VERSION=3.1.3
ARG ARG_JDBC_VERSION=42.7.6
ARG MYSQL_CONNECTOR_VERSION=8.0.25
ARG ARG_MYSQL_CLIENT_VERSION=8.0.42-0ubuntu0.24.04.1
ARG LOG4J_SCANNER_VERSION=2.25.0
ARG JMX_PROMETHEUS_JAVAAGENT_VERSION=1.0.1
ARG JMX_PORT=9025

ENV HADOOP_VERSION=$ARG_HADOOP_VERSION
ENV METASTORE_VERSION=$ARG_METASTORE_VERSION
ENV JDBC_VERSION=$ARG_JDBC_VERSION
ENV MYSQL_CLIENT_VERSION=$ARG_MYSQL_CLIENT_VERSION

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-client \
    sudo \
    curl \
    mysql-client=${MYSQL_CLIENT_VERSION} && \
    apt-get clean -y

WORKDIR /opt

RUN if echo $METASTORE_VERSION | grep -E '^3\.' > /dev/null; then \
        curl -L https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar xvzf -; \
    elif echo $METASTORE_VERSION | grep -E '^4\.' > /dev/null; then \
        curl -L https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore-server/${METASTORE_VERSION}/hive-standalone-metastore-server-${METASTORE_VERSION}-bin.tar.gz | tar xvzf -; \
    fi

# download and install hadoop and fix the (>= ubuntu jammy) distribution executable bug
RUN curl -L https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    sed -i 's|if \[\[ ! -x "\$JAVA" \]\]; then|if [ \$("$JAVA" -version) ]; then|' ${HADOOP_HOME}/libexec/hadoop-functions.sh

RUN curl -sL https://jdbc.postgresql.org/download/postgresql-${JDBC_VERSION}.jar -o /opt/apache-hive-metastore-${METASTORE_VERSION}-bin/lib/postgresql-${JDBC_VERSION}.jar

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
    && mkdir /opt/prometheus \
    && mv jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar /opt/prometheus/ \
    && chmod 644 /opt/prometheus/jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar

COPY docker/config.yaml /opt/prometheus

COPY docker/metastore.sh /metastore.sh

RUN groupadd -r hive --gid=996 && \
    useradd -r -g hive --uid=996 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive -R /opt/prometheus  && \
    chown hive:hive /metastore.sh && chmod +x /metastore.sh

# Security breach, but must be in a namespace with relaxed psp to be able to sudo
COPY docker/hive.sudoer /etc/sudoers.d/hive

USER 996

ENV HADOOP_OPTS="$HADOOP_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9026 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -javaagent:/opt/prometheus/jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar=${JMX_PORT}:/opt/prometheus/config.yaml"

EXPOSE 9083
EXPOSE ${JMX_PORT}

ENTRYPOINT ["sh", "-c", "/metastore.sh"]
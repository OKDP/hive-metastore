FROM eclipse-temurin:17-jre-noble

ARG ARG_HADOOP_VERSION=3.3.6
ARG ARG_METASTORE_VERSION=3.1.3
ARG ARG_JDBC_VERSION=42.7.7
ARG MYSQL_CONNECTOR_VERSION=8.0.25
ARG ARG_MYSQL_CLIENT_VERSION=8.0.43-0ubuntu0.24.04.1
ARG LOG4J_SCANNER_VERSION=2.25.0
ARG JMX_PROMETHEUS_JAVAAGENT_VERSION=1.0.1
ARG JMX_PORT=9025
ARG GCS_CONNECTOR_VERSION=3.0.9
ARG GOOGLE_CLOUD_STORAGE_VERSION=2.22.0
ARG GOOGLE_AUTH_LIBRARY_VERSION=1.19.0
ARG GOOGLE_HTTP_CLIENT_VERSION=1.43.0

ENV HADOOP_VERSION=$ARG_HADOOP_VERSION
ENV METASTORE_VERSION=$ARG_METASTORE_VERSION
ENV JDBC_VERSION=$ARG_JDBC_VERSION
ENV MYSQL_CLIENT_VERSION=$ARG_MYSQL_CLIENT_VERSION
ENV GCS_CONNECTOR_VERSION=$GCS_CONNECTOR_VERSION
ENV GOOGLE_CLOUD_STORAGE_VERSION=$GOOGLE_CLOUD_STORAGE_VERSION
ENV GOOGLE_AUTH_LIBRARY_VERSION=$GOOGLE_AUTH_LIBRARY_VERSION
ENV GOOGLE_HTTP_CLIENT_VERSION=$GOOGLE_HTTP_CLIENT_VERSION

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin
ENV HADOOP_CONF_DIR=/etc/hadoop/conf
ENV HIVE_CONF_DIR=/etc/hive/conf

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-client \
    sudo \
    curl \
    mysql-client=${MYSQL_CLIENT_VERSION} && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

WORKDIR /opt

RUN if echo $METASTORE_VERSION | grep -E '^3\.' > /dev/null; then \
        curl -L https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar xvzf -; \
    elif echo $METASTORE_VERSION | grep -E '^4\.' > /dev/null; then \
        curl -L https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore-server/${METASTORE_VERSION}/hive-standalone-metastore-server-${METASTORE_VERSION}-bin.tar.gz | tar xvzf -; \
    fi

# download and install hadoop and fix the (>= ubuntu jammy) distribution executable bug
RUN set -eux; \
    curl -L https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    sed -i 's|if \[\[ ! -x "\$JAVA" \]\]; then|if [ \$("$JAVA" -version) ]; then|' ${HADOOP_HOME}/libexec/hadoop-functions.sh && \
    echo "Cleaning up unnecessary Hadoop components for Hive Metastore..." && \
    rm -rf ${HADOOP_HOME}/share/hadoop/yarn/* && \
    rm -rf ${HADOOP_HOME}/share/hadoop/mapreduce/* && \
    rm -rf ${HADOOP_HOME}/share/hadoop/client/* && \
    find ${HADOOP_HOME}/share/hadoop -type d \( \
        -name "jdiff" -o \
        -name "test" -o \
        -name "examples" \
    \) -exec rm -rf {} + && \
    rm -rf ${HADOOP_HOME}/share/doc && \
    rm -rf ${HADOOP_HOME}/share/hadoop/hdfs/webapps && \
    find ${HADOOP_HOME}/share/hadoop -type d -name "webapps" -exec rm -rf {} + && \
    echo "Verify what remains" && \
    du -sh ${HADOOP_HOME}/share/hadoop/* || true && \
    echo "Hadoop cleanup completed."

RUN rm -f ${HIVE_HOME}/lib/postgresql-*.jar && \ 
    curl -sL https://jdbc.postgresql.org/download/postgresql-${JDBC_VERSION}.jar -o /opt/apache-hive-metastore-${METASTORE_VERSION}-bin/lib/postgresql-${JDBC_VERSION}.jar

# download and install mysql-connector-java
RUN curl -sLO "https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar" --output mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar \
    && mv mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar ${HIVE_HOME}/lib/

# download the log4shell scanner and run it on different paths
RUN curl -sLO https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/${LOG4J_SCANNER_VERSION}/log4j-core-${LOG4J_SCANNER_VERSION}.jar \
    && java -jar log4j-core-${LOG4J_SCANNER_VERSION}.jar --scan-log4j1 --scan-zip --scan-logback --force-fix /usr/lib || true \
    && java -jar log4j-core-${LOG4J_SCANNER_VERSION}.jar --scan-log4j1 --scan-zip --scan-logback --force-fix /var/lib || true \
    && java -jar log4j-core-${LOG4J_SCANNER_VERSION}.jar --scan-log4j1 --scan-zip --scan-logback --force-fix /opt || true \
    && rm log4j-core-${LOG4J_SCANNER_VERSION}.jar

# add the Prometheus JMX exporter Java agent jar for exposing metrics
RUN curl -sLO https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_PROMETHEUS_JAVAAGENT_VERSION}/jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar \
    && mkdir /opt/prometheus \
    && mv jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar /opt/prometheus/ \
    && chmod 644 /opt/prometheus/jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar


# Download and install GCS connector and Google Cloud Storage dependencies
RUN mkdir -p ${HIVE_HOME}/lib/ && \
    curl -sLO "https://repo1.maven.org/maven2/com/google/cloud/bigdataoss/gcs-connector/${GCS_CONNECTOR_VERSION}/gcs-connector-${GCS_CONNECTOR_VERSION}-sources.jar" && \ 
    mv gcs-connector-${GCS_CONNECTOR_VERSION}-sources.jar ${HIVE_HOME}/lib/ && \
    curl -sLO "https://repo1.maven.org/maven2/com/google/cloud/google-cloud-storage/${GOOGLE_CLOUD_STORAGE_VERSION}/google-cloud-storage-${GOOGLE_CLOUD_STORAGE_VERSION}.jar" && \
    mv google-cloud-storage-${GOOGLE_CLOUD_STORAGE_VERSION}.jar ${HIVE_HOME}/lib/ && \
    curl -sLO "https://repo1.maven.org/maven2/com/google/auth/google-auth-library-oauth2-http/${GOOGLE_AUTH_LIBRARY_VERSION}/google-auth-library-oauth2-http-${GOOGLE_AUTH_LIBRARY_VERSION}.jar" && \
    mv google-auth-library-oauth2-http-${GOOGLE_AUTH_LIBRARY_VERSION}.jar ${HIVE_HOME}/lib/ && \
    curl -sLO "https://repo1.maven.org/maven2/com/google/http-client/google-http-client-jackson2/${GOOGLE_HTTP_CLIENT_VERSION}/google-http-client-jackson2-${GOOGLE_HTTP_CLIENT_VERSION}.jar" && \
    mv google-http-client-jackson2-${GOOGLE_HTTP_CLIENT_VERSION}.jar ${HIVE_HOME}/lib/ && \
    curl -sLO "https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-latest-hadoop3.jar" && \
    mv gcs-connector-latest-hadoop3.jar ${HIVE_HOME}/lib/ && \
    chmod 644 ${HIVE_HOME}/lib/*.jar && \
    export GCS_CONNECTOR_JAR_HIVE="${HIVE_HOME}/lib/gcs-connector-${GCS_CONNECTOR_VERSION}-sources.jar" && \
    export GCS_CONNECTOR_JAR_HADOOP="${HADOOP_HOME}/share/hadoop/common/lib/gcs-connector-${GCS_CONNECTOR_VERSION}-sources.jar" && \
    export GCS_CLIENT_HTTP_JAR_HIVE="${HIVE_HOME}/lib/google-http-client-jackson2-${GOOGLE_HTTP_CLIENT_VERSION}.jar" && \
    export GCS_CLIENT_HTTP_JAR_HADOOP="${HADOOP_HOME}/share/hadoop/common/lib/google-http-client-jackson2-${GOOGLE_HTTP_CLIENT_VERSION}.jar" && \
    export GCS_CLOUD_STORAGE_JAR_HIVE="${HIVE_HOME}/lib/google-cloud-storage-${GOOGLE_CLOUD_STORAGE_VERSION}.jar" && \
    export GCS_CLOUD_STORAGE_JAR_HADOOP="${HADOOP_HOME}/share/hadoop/common/lib/google-cloud-storage-${GOOGLE_CLOUD_STORAGE_VERSION}.jar" && \
    export GCS_OAUTH_JAR_HIVE="${HIVE_HOME}/lib/google-auth-library-oauth2-http-${GOOGLE_AUTH_LIBRARY_VERSION}.jar" && \
    export GCS_OAUTH_JAR_HADOOP="${HADOOP_HOME}/share/hadoop/common/lib/google-auth-library-oauth2-http-${GOOGLE_AUTH_LIBRARY_VERSION}.jar" && \
    export GCS_HADOOP_CONNECTOR_JAR_HIVE="${HIVE_HOME}/lib/gcs-connector-latest-hadoop3.jar" && \
    export GCS_HADOOP_CONNECTOR_JAR_HADOOP="${HADOOP_HOME}/share/hadoop/common/lib/gcs-connector-latest-hadoop3.jar" && \
    cp "${GCS_CONNECTOR_JAR_HIVE}" "${GCS_CONNECTOR_JAR_HADOOP}" && \
    cp "${GCS_CLIENT_HTTP_JAR_HIVE}" "${GCS_CLIENT_HTTP_JAR_HADOOP}" && \
    cp "${GCS_CLOUD_STORAGE_JAR_HIVE}" "${GCS_CLOUD_STORAGE_JAR_HADOOP}" && \
    cp "${GCS_OAUTH_JAR_HIVE}" "${GCS_OAUTH_JAR_HADOOP}" && \
    cp "${GCS_HADOOP_CONNECTOR_JAR_HIVE}" "${GCS_HADOOP_CONNECTOR_JAR_HADOOP}" && \
    chown ubuntu:ubuntu "${GCS_CONNECTOR_JAR_HADOOP}" && \
    chown ubuntu:ubuntu "${GCS_CLIENT_HTTP_JAR_HADOOP}" && \
    chown ubuntu:ubuntu "${GCS_CLOUD_STORAGE_JAR_HADOOP}" && \
    chown ubuntu:ubuntu "${GCS_OAUTH_JAR_HADOOP}" && \
    chown ubuntu:ubuntu "${GCS_HADOOP_CONNECTOR_JAR_HADOOP}" && \
    export GCS_CONNECTOR_JAR="${GCS_CONNECTOR_JAR_HADOOP}"

# Ensure both GCS and AWS connectors are on the Hadoop classpath
RUN echo "export HADOOP_CLASSPATH=\${HADOOP_CLASSPATH}:${HADOOP_HOME}/share/hadoop/common/lib/gcs-connector-${GCS_CONNECTOR_VERSION}-sources.jar" \
    >> ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    echo "export HADOOP_CLASSPATH=\${HADOOP_CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar" \
    >> ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

RUN sed -i '/<\/configuration>/i \
  <property>\n\
    <name>fs.gs.impl</name>\n\
    <value>com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem</value>\n\
  </property>\n\
  <property>\n\
    <name>fs.AbstractFileSystem.gs.impl</name>\n\
    <value>com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS</value>\n\
  </property>' \
  ${HADOOP_HOME}/etc/hadoop/core-site.xml

COPY docker/config.yaml /opt/prometheus

COPY docker/metastore.sh /metastore.sh

RUN groupadd -r hive --gid=996 && \
    useradd -r -g hive --uid=996 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive -R ${HADOOP_HOME} && \
    chown hive:hive -R /opt/prometheus  && \
    chown hive:hive /metastore.sh && chmod +x /metastore.sh

# Security breach, but must be in a namespace with relaxed psp to be able to sudo
COPY docker/hive.sudoer /etc/sudoers.d/hive

# Link the actual Hadoop and Hive configuration directories to the standard locations
RUN mkdir -p "$(dirname "$HADOOP_CONF_DIR")" && \
    mkdir -p "$(dirname "$HIVE_CONF_DIR")" && \
    ln -sf "${HADOOP_HOME}/etc/hadoop" "${HADOOP_CONF_DIR}" && \
    ln -sf "${HIVE_HOME}/conf" "${HIVE_CONF_DIR}"

USER 996

ENV HADOOP_OPTS="$HADOOP_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9026 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -javaagent:/opt/prometheus/jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar=${JMX_PORT}:/opt/prometheus/config.yaml"

EXPOSE 9083
EXPOSE ${JMX_PORT}

ENTRYPOINT ["sh", "-c", "/metastore.sh"]
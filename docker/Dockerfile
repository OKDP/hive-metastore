

# Take reference From:
#   https://github.com/apache/spark-docker
#   3.5.0/scala2.12-java11-ubuntu/Dockerfile
#
#  https://hub.docker.com/_/eclipse-temurin/tags?page=1&name=11-jre-focal
#
#  NB: Got jdbc issue with FROM eclipse-temurin:8u402-b06-jre-alpine
#
FROM eclipse-temurin:11-jre-focal

ARG ARG_HADOOP_VERSION=3.2.0
ARG ARG_METASTORE_VERSION=3.1.3
ARG ARG_JDBC_VERSION=42.7.3
ARG MYSQL_CONNECTOR_VERSION=8.0.25

ENV HADOOP_VERSION=$ARG_HADOOP_VERSION
ENV METASTORE_VERSION=$ARG_METASTORE_VERSION
ENV JDBC_VERSION=$ARG_JDBC_VERSION
ENV MYSQL_CLIENT_VERSION="8.0.41-0ubuntu0.20.04.1"

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin

RUN apt-get update && \
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
RUN curl -sL0 "https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar" --output mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar \
    && mv mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar ${HIVE_HOME}/lib/

COPY docker/metastore.sh /metastore.sh

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /metastore.sh && chmod +x /metastore.sh

# Security breach, but must be in a namespace with relaxed psp to be able to sudo
COPY docker/hive.sudoer /etc/sudoers.d/hive

USER 1000
EXPOSE 9083

ENTRYPOINT ["sh", "-c", "/metastore.sh"]

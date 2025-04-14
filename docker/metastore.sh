#!/bin/sh


MODE=$1

if [ "$MODE" = "hms" ]; then
  echo "Will run metastore"
elif [ "$MODE" = "init" ]; then
  echo "Will initialize DB if not yet done"
else
  echo "First parameter must be 'hms' or 'init'"
  exit 20
fi

if [ -z "${HIVEMS_DB}" ]; then echo "HIVEMS_DB env variable must be defined!"; exit 1; fi
if [ -z "${HIVEMS_USER}" ]; then echo "HIVEMS_USER env variable must be defined!"; exit 1; fi
if [ -z "${HIVEMS_PASSWORD}" ]; then echo "HIVEMS_PASSWORD env variable must be defined!"; exit 1; fi
if [ -z "${DB_DRIVER_REF}" ]; then echo "DB_DRIVER_REF env variable must be defined!"; exit 1; fi
if [ -z "${DB_DRIVER_NAME}" ]; then echo "DB_DRIVER_NAME env variable must be defined!"; exit 1; fi
if [ -z "${DB_HOST}" ]; then echo "DB_HOST env variable must be defined!"; exit 1; fi
if [ -z "${DB_PORT}" ]; then echo "DB_PORT env variable must be defined!"; exit 1; fi
if [ -z "${METASTORE_VERSION}" ]; then echo "METASTORE_VERSION env variable must be defined!"; exit 1; fi
if [ -z "${HADOOP_VERSION}" ]; then echo "HADOOP_VERSION env variable must be defined!"; exit 1; fi

# May be null in case of usage of AWS instance roles
#if [ -z "${S3_ENDPOINT}" ]; then echo "S3_ENDPOINT env variable must be defined!"; exit 1; fi
#if [ -z "${S3_ACCESS_KEY}" ]; then echo "S3_ACCESS_KEY env variable must be defined!"; exit 1; fi
#if [ -z "${S3_SECRET_KEY}" ]; then echo "S3_SECRET_KEY env variable must be defined!"; exit 1; fi

if [ -z "${JAVA_HOME}" ]; then export JAVA_HOME=/usr/local/openjdk-8; fi
if [ -z "${BASEDIR}" ]; then export BASEDIR=/opt; fi
if [ -z "${LOG_LEVEL}" ]; then export LOG_LEVEL=INFO; fi
if [ -z "${THRIFT_LISTENING_PORT}" ]; then export THRIFT_LISTENING_PORT=9083; fi
if [ -z "${S3_REQUEST_TIMEOUT}" ]; then export S3_REQUEST_TIMEOUT=0; fi

export HADOOP_HOME=${BASEDIR}/hadoop-${HADOOP_VERSION}
export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar

echo ""
echo "METASTORE_VERSION=$METASTORE_VERSION"
echo "HADOOP_VERSION=$HADOOP_VERSION"
echo ""

cat >${BASEDIR}/apache-hive-metastore-${METASTORE_VERSION}-bin/conf/metastore-log4j2.properties <<-EOF
status = INFO
name = MetastoreLog4j2
packages = org.apache.hadoop.hive.metastore
# list of all appenders
appenders = console
# console appender
appender.console.type = Console
appender.console.name = console
appender.console.target = SYSTEM_ERR
appender.console.layout.type = PatternLayout
appender.console.layout.pattern = %d{ISO8601} %5p [%t] %c{2}: %m%n
# list of all loggers
loggers = DataNucleus, Datastore, JPOX, PerfLogger
logger.DataNucleus.name = DataNucleus
logger.DataNucleus.level = ERROR
logger.Datastore.name = Datastore
logger.Datastore.level = ERROR
logger.JPOX.name = JPOX
logger.JPOX.level = ERROR
logger.PerfLogger.name = org.apache.hadoop.hive.ql.log.PerfLogger
logger.PerfLogger.level = INFO
# root logger
rootLogger.level = ${LOG_LEVEL}
rootLogger.appenderRefs = root
rootLogger.appenderRef.root.ref = console
EOF

cat >${BASEDIR}/apache-hive-metastore-${METASTORE_VERSION}-bin/conf/metastore-site.xml <<-EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>metastore.thrift.uris</name>
    <value>thrift://localhost:9083</value>
    <description>Thrift URI for the remote metastore. Used by metastore client to connect to remote metastore.</description>
  </property>
  <property>
    <name>metastore.task.threads.always</name>
    <value>org.apache.hadoop.hive.metastore.events.EventCleanerTask,org.apache.hadoop.hive.metastore.MaterializationsRebuildLockCleanerTask</value>
  </property>
  <property>
    <name>metastore.expression.proxy</name>
    <value>org.apache.hadoop.hive.metastore.DefaultPartitionExpressionProxy</value>
  </property>
  <property>
    <name>metastore.server.min.threads</name>
    <value>5</value>
  </property>
  <property>
    <name>metastore.server.max.threads</name>
    <value>20</value>
  </property>
  <property>
    <name>javax.jdo.option.Multithreaded</name>
    <value>true</value>
    <description>Set this to true if multiple threads access metastore through JDO concurrently.</description>
  </property>
  <property>
    <name>javax.jdo.PersistenceManagerFactoryClass</name>
    <value>org.datanucleus.api.jdo.JDOPersistenceManagerFactory</value>
    <description>class implementing the jdo persistence</description>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>${DB_DRIVER_REF}</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:${DB_DRIVER_NAME}://${DB_HOST}:${DB_PORT}/${HIVEMS_DB}</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>${HIVEMS_USER}</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>${HIVEMS_PASSWORD}</value>
  </property>
  <property>
    <name>fs.s3a.path.style.access</name>
    <value>true</value>
  </property>
  <property>
    <name>fs.s3a.connection.request.timeout</name>
    <value>${S3_REQUEST_TIMEOUT}</value>
  </property>
EOF

if [ ! -z "${S3_ENDPOINT}" ]
then
cat >>${BASEDIR}/apache-hive-metastore-${METASTORE_VERSION}-bin/conf/metastore-site.xml <<-EOF
  <property>
    <name>fs.s3a.endpoint</name>
    <value>${S3_ENDPOINT}</value>
  </property>
EOF
fi

if [ ! -z "${S3_ACCESS_KEY}" ]
then
cat >>${BASEDIR}/apache-hive-metastore-${METASTORE_VERSION}-bin/conf/metastore-site.xml <<-EOF
  <property>
    <name>fs.s3a.access.key</name>
    <value>${S3_ACCESS_KEY}</value>
  </property>
  <property>
    <name>fs.s3a.secret.key</name>
    <value>${S3_SECRET_KEY}</value>
  </property>
EOF
fi

if [ ! -z "${ASSUME_ROLE_ARN}" ]
then
cat >>${BASEDIR}/apache-hive-metastore-${METASTORE_VERSION}-bin/conf/metastore-site.xml <<-EOF
  <property>
    <name>fs.s3a.aws.credentials.provider</name>
    <value>org.apache.hadoop.fs.s3a.auth.AssumedRoleCredentialProvider</value>
  </property>
  <property>
    <name>fs.s3a.assumed.role.credentials.provider</name>
    <value>com.amazonaws.auth.InstanceProfileCredentialsProvider</value>
  </property>
  <property>
    <name>fs.s3a.assumed.role.arn</name>
    <value>${ASSUME_ROLE_ARN}</value>
  </property>
EOF
fi

cat >>${BASEDIR}/apache-hive-metastore-${METASTORE_VERSION}-bin/conf/metastore-site.xml <<-EOF
</configuration>
EOF

# set +x

export PGPASSWORD=${HIVEMS_PASSWORD}

echo "Will wait for ${DB_DRIVER_NAME} server to be ready"
if [ "$DB_DRIVER_NAME" = "mysql" ]; then
    while ! mysqladmin ping --host=${DB_HOST} --port=${DB_PORT} --silent; do echo "Waiting for ${DB_DRIVER_NAME} to be ready..."; sleep 2; done;
else
    while ! pg_isready --host=${DB_HOST} --port=${DB_PORT}; do echo "Waiting for ${DB_DRIVER_NAME} to be ready..."; sleep 2; done;
fi

echo "Will wait for \"${HIVEMS_DB}\" to exist"
if [ "$DB_DRIVER_NAME" = "mysql" ]; then
    while ! mysql --host=${DB_HOST} --port=${DB_PORT} -u ${HIVEMS_USER} -p${HIVEMS_PASSWORD} -e "USE ${HIVEMS_DB};" >/dev/null 2>&1; do echo "Waiting for ${HIVEMS_DB} database to be ready..."; sleep 2; done;
else
    while ! psql --host=${DB_HOST} --port=${DB_PORT} -U ${HIVEMS_USER} -d ${HIVEMS_DB} -c "\c ${HIVEMS_DB}" >/dev/null 2>&1; do echo "Waiting for ${HIVEMS_DB} database to be ready..."; sleep 2; done;
fi

if [ "$MODE" = "init" ]; then
    echo "Initialize schema if DBS table does not exist"
    if [ "$DB_DRIVER_NAME" = "mysql" ]; then
        mysql --host=${DB_HOST} --port=${DB_PORT} -u ${HIVEMS_USER} -p${HIVEMS_PASSWORD} -D ${HIVEMS_DB} -e 'SELECT "DB_ID" FROM "DBS"' >/dev/null 2>&1;
        if [ $? -ne 0 ]; then echo "Will initialize the DB"; ${BASEDIR}/apache-hive-metastore-${METASTORE_VERSION}-bin/bin/schematool -initSchema -dbType ${DB_DRIVER_NAME}; fi
    else
        psql --host=${DB_HOST} --port=${DB_PORT} -U ${HIVEMS_USER} -d ${HIVEMS_DB} -c 'SELECT "DB_ID" FROM "DBS"' >/dev/null 2>&1;
        if [ $? -ne 0 ]; then echo "Will initialize the DB"; ${BASEDIR}/apache-hive-metastore-${METASTORE_VERSION}-bin/bin/schematool -initSchema -dbType ${DB_DRIVER_NAME}; fi
    fi
    echo "DATABASE SCHEMA SHOULD BE OK NOW!!"
    exit 0
fi

# MODE = "hms" here

echo "Will wait for database schema to be ready...."
if [ "$DB_DRIVER_NAME" = "mysql" ]; then
    while ! mysql --host=${DB_HOST} --port=${DB_PORT} -u ${HIVEMS_USER} -p${HIVEMS_PASSWORD} -D ${HIVEMS_DB} -e 'SELECT "SCHEMA_VERSION" FROM "VERSION"' >/dev/null 2>&1; do echo "Waiting for ${HIVEMS_DB} schema to be ready..."; sleep 2; done;
else
    while ! psql --host=${DB_HOST} --port=${DB_PORT} -U ${HIVEMS_USER} -d ${HIVEMS_DB} -c 'SELECT "SCHEMA_VERSION" FROM "VERSION"' >/dev/null 2>&1; do echo "Waiting for ${HIVEMS_DB} schema to be ready..."; sleep 2; done;
fi
echo "DATABASE SCHEMA IS OK. CAN LAUNCH!!"
echo ""

unset PGPASSWORD

export HADOOP_CLIENT_OPTS="$HADOOP_CLIENT_OPTS -Dcom.amazonaws.sdk.disableCertChecking=true"

# WARNING: This variable is set by Kubernetes in a form: tcp://XX.XX.XX.XX:9083.
# For the metastore, this is an entry variable hosting only the listening port, as a single number. So failure.
unset METASTORE_PORT

${BASEDIR}/apache-hive-metastore-${METASTORE_VERSION}-bin/bin/start-metastore -p $THRIFT_LISTENING_PORT
err=$?

if [ -n "$WAIT_ON_ERROR" ]; then
  if [ $err -ne 0 ]; then
    echo "ERROR: rc=$err. Will wait $WAIT_ON_ERROR sec...."
    sleep $WAIT_ON_ERROR
  fi
fi

return $err



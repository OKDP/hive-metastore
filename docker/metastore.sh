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

if [ -z "${LOG_LEVEL}" ]; then export LOG_LEVEL=INFO; fi
if [ -z "${THRIFT_LISTENING_PORT}" ]; then export THRIFT_LISTENING_PORT=9083; fi
if [ -z "${S3_REQUEST_TIMEOUT}" ]; then export S3_REQUEST_TIMEOUT=0; fi

# GCS connector JAR locations - require explicit version
# if [ -z "${GCS_CONNECTOR_VERSION}" ]; then
#     echo "ERROR: GCS_CONNECTOR_VERSION environment variable must be specified when using GCS storage"
#     exit 1
# fi

echo ""
echo "METASTORE_VERSION=$METASTORE_VERSION"
echo "HADOOP_VERSION=$HADOOP_VERSION"
echo "JAVA_HOME=$JAVA_HOME"
echo ""

cat >${HIVE_CONF_DIR}/metastore-log4j2.properties <<-EOF
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

cat >${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
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
    <!-- GCS connector configuration -->
  <property>
    <name>fs.gs.impl</name>
    <value>com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem</value>
    <description>The FileSystem implementation for gs: URIs</description>
  </property>
  <!-- AWS (S3A) connector configuration -->
  <property>
    <name>fs.s3a.impl</name>
    <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
  </property>
EOF

# Add GCS configuration if environment variables are set
if [ ! -z "${GCS_PROJECT_ID}" ]; then
cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
  <property>
    <name>fs.gs.project.id</name>
    <value>${GCS_PROJECT_ID}</value>
    <description>Google Cloud Project ID</description>
  </property>
EOF
fi
if [ ! -z "${GCS_WORKLOAD_IDENTITY_ENABLED}" ] && [ "${GCS_WORKLOAD_IDENTITY_ENABLED}" = "true" ]; then
  # Workload Identity Federation configuration
  echo "Using Workload Identity Federation for GCS authentication"
  
  cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
  <property>
    <name>fs.gs.auth.type</name>
    <value>COMPUTE</value>
  </property>
EOF
# If a service account is specified for impersonation with WIF
if [ ! -z "${GCS_IMPERSONATION_SERVICE_ACCOUNT}" ]; then
  cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
  <property>
    <name>fs.gs.auth.impersonation.service.account</name>
    <value>${GCS_IMPERSONATION_SERVICE_ACCOUNT}</value>
  </property>
EOF
fi
elif [ ! -z "${GCS_SERVICE_ACCOUNT_JSON_KEYFILE}" ]; then
cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
  <property>
    <name>google.cloud.auth.service.account.enable</name>
    <value>true</value>
  </property>
  <property>
    <name>google.cloud.auth.service.account.json.keyfile</name>
    <value>/var/secrets/google/key.json</value>
  </property>
EOF
fi

if [ ! -z "${GCS_WAREHOUSE_DIRECTORY}" ]; then
cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
  <property>
    <name>metastore.warehouse.dir</name>
    <value>gs://${GCS_WAREHOUSE_DIRECTORY}/hive-warehouse/</value>
  </property>
EOF
fi

if [ ! -z "${S3_ENDPOINT}" ]
then
cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
  <property>
    <name>fs.s3a.endpoint</name>
    <value>${S3_ENDPOINT}</value>
  </property>
EOF
fi

if [ ! -z "${S3_ACCESS_KEY}" ]
then
cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
  <property>
    <name>fs.s3a.access.key</name>
    <value>${S3_ACCESS_KEY}</value>
  </property>
  <property>
    <name>fs.s3a.secret.key</name>
    <value>${S3_SECRET_KEY}</value>
  </property>
  <property>
      <name>fs.s3a.aws.credentials.provider</name>
      <value>org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider</value>
  </property>
EOF
fi

if [ ! -z "${S3_WAREHOUSE_DIRECTORY}" ]
then
cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
  <property>
    <name>metastore.warehouse.dir</name>
    <value>s3a://${S3_WAREHOUSE_DIRECTORY}/hive-warehouse/</value>
  </property>
EOF
fi

if [ ! -z "${S3_PROXY_HOST}" ]
then
cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
  <property>
    <name>fs.s3a.proxy.host</name>
    <value>${S3_PROXY_HOST}</value>
  </property>
  <property>
    <name>fs.s3a.proxy.port</name>
    <value>${S3_PROXY_PORT}</value>
  </property>
EOF
fi

if [ ! -z "${ASSUME_ROLE_ARN}" ]
then
cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
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

cat >>${HIVE_CONF_DIR}/metastore-site.xml <<-EOF
</configuration>
EOF

### Override the configuration:
#### Expand env variables and place them inside $HADOOP_CONF_DIR and $HIVE_CONF_DIR
[ -d /tmp/envsubst ] && find /tmp/envsubst -type f | while read -r src; do
  dest="${src#/tmp/envsubst}"
  eval "cat <<EOF > \"$dest\"
$(cat "$src")
EOF"
done

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
        if [ $? -ne 0 ]; then echo "Will initialize the DB"; ${HIVE_HOME}/bin/schematool -initSchema -dbType ${DB_DRIVER_NAME} -userName ${HIVEMS_USER} -passWord ${HIVEMS_PASSWORD} -url "jdbc:mysql://${DB_HOST}:${DB_PORT}/${HIVEMS_DB}?createDatabaseIfNotExist=true&connectTimeout=1000"; fi
    else
        psql --host=${DB_HOST} --port=${DB_PORT} -U ${HIVEMS_USER} -d ${HIVEMS_DB} -c 'SELECT "DB_ID" FROM "DBS"' >/dev/null 2>&1;
        if [ $? -ne 0 ]; then echo "Will initialize the DB"; ${HIVE_HOME}/bin/schematool -initSchema -dbType postgres; fi
    fi
    echo "DATABASE SCHEMA SHOULD BE OK NOW!!"
    exit 0
fi

# MODE = "hms" here

echo "Will wait for database schema to be ready...."
if [ "$DB_DRIVER_NAME" = "mysql" ]; then
    while ! mysql --host=${DB_HOST} --port=${DB_PORT} -u ${HIVEMS_USER} -p${HIVEMS_PASSWORD} -D ${HIVEMS_DB} -e "SELECT "SCHEMA_VERSION" FROM "VERSION"" >/dev/null 2>&1; do echo "Waiting for ${HIVEMS_DB} schema to be ready..."; sleep 2; done;
else
    while ! psql --host=${DB_HOST} --port=${DB_PORT} -U ${HIVEMS_USER} -d ${HIVEMS_DB} -c 'SELECT "SCHEMA_VERSION" FROM "VERSION"' >/dev/null 2>&1; do echo "Waiting for ${HIVEMS_DB} schema to be ready..."; sleep 2; done;
fi
echo "DATABASE SCHEMA IS OK. CAN LAUNCH!!"
echo ""

unset PGPASSWORD

export HADOOP_CLIENT_OPTS="$HADOOP_CLIENT_OPTS -Dcom.amazonaws.sdk.disableCertChecking=true"

# Set Google Application Credentials environment variable if file exists
if [ ! -z "${GCS_SERVICE_ACCOUNT_JSON_KEYFILE}" ] && [ -f "${GCS_SERVICE_ACCOUNT_JSON_KEYFILE}" ]; then
  export GOOGLE_APPLICATION_CREDENTIALS="${GCS_SERVICE_ACCOUNT_JSON_KEYFILE}"
fi

# WARNING: This variable is set by Kubernetes in a form: tcp://XX.XX.XX.XX:9083.
# For the metastore, this is an entry variable hosting only the listening port, as a single number. So failure.
unset METASTORE_PORT

${HIVE_HOME}/bin/start-metastore -p $THRIFT_LISTENING_PORT
err=$?

if [ -n "$WAIT_ON_ERROR" ]; then
  if [ $err -ne 0 ]; then
    echo "ERROR: rc=$err. Will wait $WAIT_ON_ERROR sec...."
    sleep $WAIT_ON_ERROR
  fi
fi

return $err
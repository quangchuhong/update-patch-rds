1. upgrade rds engine version of a DB instance, aws cli for rds

# modify 
aws rds modify-db-instance \
    --db-instance-identifier quangch-rds-upgrade-test \
    --engine-version 13.11 \
    --allow-major-version-upgrade \
    --db-parameter-group-name dbparametergroup15 \
    --apply-immediately

# the valid upgrade targets for a rds database:
# validate version upgrade rds db, version 13 lên thẳng được version 15. đúng với các bản chạy lệnh validate aws rds.

aws rds describe-db-engine-versions \
  --engine postgres \
  --engine-version 13.14 \
  --query "DBEngineVersions[*].ValidUpgradeTarget[*].{EngineVersion:EngineVersion}" --output text

# create db parameter group for postgres family
aws rds create-db-parameter-group \
    --db-parameter-group-name dbparametergroup15 \
    --db-parameter-group-family postgres15 \
    --parameters "ParameterName='clr enabled',ParameterValue=1,ApplyMethod=immediate"
    --description "My new parameter group for postgres15"

aws rds modify-db-parameter-group \
    --db-parameter-group-name test-sqlserver-se-2017 \
    --parameters "ParameterName=server_audit_logging,ParameterValue=1,ApplyMethod=immediate" \
                 "ParameterName=server_audit_logs_upload,ParameterValue=1,ApplyMethod=immediate"


aws rds modify-db-cluster-parameter-group \
    --db-cluster-parameter-group-name mydbclusterpg \
    --parameters "ParameterName=server_audit_logging,ParameterValue=1,ApplyMethod=immediate" \
                 "ParameterName=server_audit_logs_upload,ParameterValue=1,ApplyMethod=immediate"


# "ParameterName='track_activity_query_size',ParameterValue=102400,ApplyMethod=pending-reboot" 

aws rds create-db-parameter-group \
    --db-parameter-group-name test-create-dbparametergroup16 \
    --db-parameter-group-family postgres16 \
    --description "My new parameter group for postgres16" \









!! fixed
# "ParameterName='log_min_error_statement',ParameterValue='warning',ApplyMethod=immediate" 
# "ParameterName='shared_preload_libraries',ParameterValue='pg_stat_statements,pg_cron,auto_explain',ApplyMethod=immediate" --> version16 bo aws-s3
# "ParameterName='log_min_messages',ParameterValue='warning',ApplyMethod=immediate" 
# "ParameterName='log_statement',ParameterValue='ddl',ApplyMethod=immediate" 
# "ParameterName='track_functions',ParameterValue='all',ApplyMethod=immediate"
# "ParameterName='track_activity_query_size',ParameterValue=102400,ApplyMethod=immediate" 

"ParameterName='track_counts',ParameterValue=1,ApplyMethod=immediate" --> bỏ trên postgre16


# check status rds instances

aws rds describe-db-instances \
    --db-instance-identifier quangch-rds-upgrade-test \
    --query 'DBInstances[].DBInstanceStatus[]'
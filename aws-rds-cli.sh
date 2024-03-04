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




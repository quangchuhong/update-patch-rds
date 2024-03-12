pipeline {
    options {
        timestamps()
        timeout(time: 120, unit: 'MINUTES')

    }
    agent { 
        node {
            label 'jenkin-test'
            // label 'cloud-jenkins-banca-host'
        }
    }
    parameters {
        string(name: 'ENVIROMENT_AWS_ACCOUNT', defaultValue: 'banca-uat', description: 'account name einviroment')
        string(name: 'DB_INSTANCE_NAME', defaultValue: 'snapshot-tcb-dev-banca-db-backup-2023-03-09-01-44-23', description: 'rds db instance name')
        string(name: 'DB_NAME', defaultValue: 'BANCADB', description: 'rds db name')
        string(name: 'RDS_MINOR_VERSION', defaultValue: '14.7', description: 'rds minor version')
        string(name: 'RDS_VERSION_LASTEST', defaultValue: '16.2', description: 'rds version lastest')
        string(name: 'DB_NEW_PARAMETER_GROUP_FAMILY', defaultValue: 'postgres16', description: 'PARAMETER GROUP FAMILY (postgres16)')
        string(name: 'URL_JDBC_DB', defaultValue: 'jdbc:postgresql://snapshot-tcb-dev-banca-db-backup-2023-03-09-01-44-23.cmkmobqyizfz.ap-southeast-1.rds.amazonaws.com:5432/BANCADB?user=tcbdbuser&password=adf234vcdDF', description: 'PARAMETER GROUP FAMILY (postgres16)')
    }

    environment {
        GIT_CREDS  = credentials('dso-rw')
        DB_PARAMETER_GROUP_NAME = 'tcb-new-parameter-group-rds-upgrade-lastest'
    }
    stages {
        stage('Create new parametergroup') {
            steps {
                sh '''
                aws rds create-db-parameter-group \
                    --db-parameter-group-name $DB_PARAMETER_GROUP_NAME \
                    --db-parameter-group-family ${DB_NEW_PARAMETER_GROUP_FAMILY} \
                    --description "My new parameter group for ${DB_NEW_PARAMETER_GROUP_FAMILY} "

                python3 script-modify-postgres-parameter-group.py
                '''
            }
        }
        stage('upgrade minor rds version') {
            steps {
                sh '''
                aws rds modify-db-instance \
                    --db-instance-identifier ${DB_INSTANCE_NAME} \
                    --engine-version ${RDS_MINOR_VERSION} \
                    --allow-major-version-upgrade \
                    --apply-immediately
                '''
            }
        }
        stage('update extension database ') {
            steps {
                sh '''
                liquibase status \
                        --url=${URL_JDBC_DB} \
                        --username=edu --password=adf234vcdDF --changelog-file=postgres.sql
                '''
            }
        }

        stage ("Verify Rds DB") {
            steps {
                script{
                    for (int i = 0; i < 120; i++) {
                        def RDS_STATUS=sh(script:"aws rds describe-db-instances \
                                            --db-instance-identifier ${DB_INSTANCE_NAME}  \
                                            --output text \
                                            --query 'DBInstances[].DBInstanceStatus[]'",returnStdout: true).trim()

                        echo "this is a string ${RDS_STATUS}"
                        if (RDS_STATUS == 'available') {
                            echo "RDS status is ${RDS_STATUS}"
                            stage ('Upgrade Lastest Rds version') {
                                input message:'Approve Upgrade Rds?'
                                sh'''
                                aws rds modify-db-instance \
                                    --db-instance-identifier ${DB_INSTANCE_NAME} \
                                    --engine-version ${RDS_VERSION_LASTEST} \
                                    --allow-major-version-upgrade \
                                    --db-parameter-group-name ${DB_PARAMETER_GROUP_NAME} \
                                    --apply-immediately
                                '''
                            }
                            break  
                            
                        } else if(RDS_STATUS == 'upgrading')  {
                            echo "RDS status is upgrading"
                            echo "Auto Checking Rds status available, 2 minute/time"
                            sh'''sleep 60'''

                        } else {
                            stage ('Rollback - Upgrade Failed') {
                                input message:'Approve Rollback Rds?'
                                sh'''
                                echo 'rollback rds step'
                                '''
                            }
                        }
                    }
                }
            }
        }

        stage ("Verify Rds DB Version Lastest") {
            steps {
                script{
                    for (int i = 0; i < 120; i++) {
                        def RDS_STATUS=sh(script:"aws rds describe-db-instances \
                                            --db-instance-identifier ${DB_INSTANCE_NAME}  \
                                            --output text \
                                            --query 'DBInstances[].DBInstanceStatus[]'",returnStdout: true).trim()

                        echo "this is a string ${RDS_STATUS}"
                        if (RDS_STATUS == 'available') {
                            echo "RDS status is ${RDS_STATUS}"
                            stage ('UPDATE CODE TERRAFORM ON TFE') {
                                sh'''
                                git config --global user.email "quang.hong.0991@gmail.com"
                                git config --global user.name "quangchuhong"
                                git clone https://$GIT_CREDS_USR:$GIT_CREDS_PSW@github.com/quangchuhong/tfe-rds.git
                                '''
                            }
                            break  
                            
                        } else if(RDS_STATUS == 'upgrading')  {
                            echo "RDS status is upgrading"
                            echo "Auto Checking Rds status available, 2 minute/time"
                            sh'''sleep 60'''

                        } else {
                            stage ('Rollback - Upgrade Failed') {
                                input message:'Approve Rollback Rds?'
                                sh'''
                                echo 'rollback rds step'
                                '''
                            }
                        }
                        
                    }
                }
            }
        }

        stage('Update Code terraform on TFE') {
            steps {
                sh '''
                echo "Shell Process ID: $$"
                rm -rf tfe-rds/
                git config --global user.email "quang.hong.0991@gmail.com"
                git config --global user.name "quangchuhong"
                git clone https://$GIT_CREDS_USR:$GIT_CREDS_PSW@github.com/quangchuhong/tfe-rds.git
                cd tfe-rds/
                mv tf.auto.tfvars tf.auto.tfvars.ver2
                cd ..
                cp -r tf.auto.tfvars tfe-rds/
                cd tfe-rds/
                git pull
                git add *
                git commit -m 'update tfvars ver7'
                git push
                '''
            }
        }
    }
    cleanWs()
}
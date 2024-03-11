pipeline {
  options {
    timestamps()
    timeout(time: 60, unit: 'MINUTES')
    // ansiColor('xterm')
    // disableConcurrentBuilds()
    // buildDiscarder(logRotator(numToKeepStr: '250', daysToKeepStr: '5'))
  }
    agent any

    environment {
        GIT_CREDS  = credentials('git')
        DB_INSTANCE_NAME_1 = 'quangch-rds-upgrade-test'
        DB_INSTANCE_NAME_2 = 'education03'
        RDS_ENGINE_VERSION = '16.2'
        DB_PARAMETER_GROUP = 'rds-upgrade-test-postgres16-v3'
        RDS_ENGINE_VERSION_LASTEST = '16.2'
        DB_PARAMETER_GROUP_FAMILY = 'postgres16'
        
    }
    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/quangchuhong/update-patch-rds.git'
            }
        }

        stage('Create new parametergroup') {
            steps {
                sh '''#!/usr/bin/env bash
                echo "Shell Process ID: $$"
                aws rds create-db-parameter-group \
                    --db-parameter-group-name $DB_PARAMETER_GROUP \
                    --db-parameter-group-family $DB_PARAMETER_GROUP_FAMILY \
                    --description "My new parameter group for $DB_PARAMETER_GROUP_FAMILY "

                alias python3=python3.8
                python3 -m venv env
                source env/bin/activatie
                pip install boto3
                python3 script-modify-postgres-parameter-group.py
                '''
            }
        }
        stage('upgrade minor rds version') {
            steps {
                sh '''#!/usr/bin/env bash
                echo "Shell Process ID: $$"
                aws rds modify-db-instance \
                    --db-instance-identifier $DB_INSTANCE_NAME_1 \
                    --engine-version $RDS_ENGINE_VERSION \
                    --allow-major-version-upgrade \
                    --apply-immediately
                '''
            }
        }
        stage('update extension database ') {
            steps {
                sh '''#!/usr/bin/env bash
                echo "Shell Process ID: $$"
                sudo liquibase update \
                        --url="jdbc:postgresql://quangch-rds-upgrade-test.cihmxj0imzlx.ap-southeast-1.rds.amazonaws.com:5432/postgres?user=edu&password=adf234vcdDF" \
                        --username=edu --password=adf234vcdDF --changelog-file=postgres.sql
                '''
            }
        }

        stage ("wait_for_auto_checking_status_rds") {
            steps {
                script{
                    for (int i = 0; i < 120; i++) {
                        def RDS_STATUS=sh(script:"aws rds describe-db-instances \
                                            --db-instance-identifier quangch-rds-upgrade-test \
                                            --output text \
                                            --query 'DBInstances[].DBInstanceStatus[]'",returnStdout: true).trim()
                        def rds_status_test = '["available"]'
                        echo "this is a string ${RDS_STATUS}"
                        if (RDS_STATUS == 'available') {
                            echo "RDS status is ${rds_status_test}"
                            stage ('Upgrade Lastest Rds version') {
                                input message:'Approve Upgrade Rds?'
                                sh '''#!/usr/bin/env bash
                                    echo "Shell Process ID: $$"
                                    aws rds modify-db-instance \
                                        --db-instance-identifier $DB_INSTANCE_NAME_1 \
                                        --engine-version $RDS_ENGINE_VERSION_LASTEST \
                                        --allow-major-version-upgrade \
                                        --db-parameter-group-name $DB_PARAMETER_GROUP \
                                        --apply-immediately
                                '''
                            }
                            break  
                            
                        } else {
                            echo "RDS status is not available"
                            echo "Auto Checking Rds status available, 2 minute/time"
                            sh'''sleep 60'''
                        }
                        
                    }
                }
            }
        }


        stage('git clone and push code tf of TFE') {
            steps {
                sh '''#!/usr/bin/env bash
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

    post {
        failure {
            sh '''#!/usr/bin/env bash
            echo "Shell Process ID: $$"
            '''
            }
        }

}
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
        RDS_ENGINE_VERSION = '13.14'
        DB_PARAMETER_GROUP = 'rds-upgrade-test-postgres16-v2'
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

                aws rds modify-db-parameter-group \
                    --db-parameter-group-name $DB_PARAMETER_GROUP \
                    --parameters "ParameterName='log_checkpoints',ParameterValue=on" \
                                "ParameterName='log_connections',ParameterValue=on" \
                                "ParameterName='track_activity_query_size',ParameterValue=102400"         
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

        stage('Upgrade Lastest Rds version') {
            steps {
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
        }

        // stage('git clone and push code tf of TFE') {
        //     steps {
        //         sh '''#!/usr/bin/env bash
        //         echo "Shell Process ID: $$"
        //         rm -rf tfe-rds/
        //         git config --global user.email "quang.hong.0991@gmail.com"
        //         git config --global user.name "quangchuhong"
        //         git clone https://$GIT_CREDS_USR:$GIT_CREDS_PSW@github.com/quangchuhong/tfe-rds.git
        //         cd tfe-rds/
        //         mv tf.auto.tfvars tf.auto.tfvars.ver2
        //         cd ..
        //         cp -r tf.auto.tfvars tfe-rds/
        //         cd tfe-rds/
        //         git pull
        //         git add *
        //         git commit -m 'update tfvars ver2'
        //         git push
        //         '''
        //     }
        // }
    }

    post {
        failure {
            sh '''#!/usr/bin/env bash
            echo "Shell Process ID: $$"
            '''
            }
        }

}
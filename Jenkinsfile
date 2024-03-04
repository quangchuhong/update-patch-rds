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
        DB_INSTANCE_NAME = 'quangch-rds-upgrade-test'
        RDS_ENGINE_VERSION = '15.6'
        DB_PARAMETER_GROUP = 'rds-upgrade-test'
        
    }
    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/quangchuhong/update-patch-rds.git'
            }
        }


        stage('') {
            steps {
                sh '''#!/usr/bin/env bash
                echo "Shell Process ID: $$"
                aws rds modify-db-instance \
                    --db-instance-identifier $DB_INSTANCE_NAME \
                    --engine-version $RDS_ENGINE_VERSION \
                    --allow-major-version-upgrade \
                    --db-parameter-group-name $DB_PARAMETER_GROUP \
                    --apply-immediately
                '''
            }
        }
        stage('git clone and push code tf of TFE') {
            steps {
                sh '''#!/usr/bin/env bash
                echo "Shell Process ID: $$"
                git config --global user.email "quang.hong.0991@gmail.com"
                git config --global user.name "quangchuhong"
                git clone https://$GIT_CREDS_USR:$GIT_CREDS_PSW@github.com/quangchuhong/tfe-rds.git
                cd tfe-rds/
                mv tf.auto.tfvars tf.auto.tfvars.ver2
                cd ..
                cp -r tf.auto.tfvars tfe-rds/
                cd tfe-rds/
                git add *
                git commit -m 'update tfvars ver2'
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
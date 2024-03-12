node("dr-ito-jenkins-its3-01") {
    properties([
        disableConcurrentBuilds(),
        parameters([
            [
                $class: 'ChoiceParameter',
                choiceType: 'PT_SINGLE_SELECT',
                name: 'DEPLOY_ENVIRONMENT',
                script: [
                    $class: 'GroovyScript',
                    fallbackScript: [
                        classpath: [],
                        sandbox: true,
                        script:
                            'return[\'Could not get environment\']'
                    ],
                    script: [
                        classpath: [],
                        sandbox: true,
                        script:
                            '''
                            return ["DEV","PROD"]
                            '''
                    ]
                ]
            ],
            [
                $class: 'ChoiceParameter',
                choiceType: 'PT_SINGLE_SELECT',
                name: 'ACTION',
                script: [
                    $class: 'GroovyScript',
                    fallbackScript: [
                        classpath: [],
                        sandbox: true,
                        script:
                            'return[\'Could not get action\']'
                    ],
                    script: [
                        classpath: [],
                        sandbox: true,
                        script:
                            '''
                            return ["VERIFY", "ROLLOUT", "ROLLBACK"]
                            '''
                    ]
                ]
            ]
        ])
    ])

    stage('Checkout SCM') {
        def myRepo = checkout scm
        echo sh(script: 'env|sort', returnStdout: true)
    }

    env.ACTION = "${params.ACTION}"
    env.DEPLOY_ENVIRONMENT = "${params.DEPLOY_ENVIRONMENT}".toLowerCase()
    println "${env}"
    run_folder = "${env.WORKSPACE}/pipelines/test_postgres/database"
    def jenkinsVar = readProperties  file: "${run_folder}/Jenkins.properties"
    jenkinsVar.each {key, value ->
        env."${key}" = "${value}"
    }
    if (JENKINS_URL =~ /jenkins-tcb/) {
        env.VAULT_ADDR = "${env.VAULT_ADDR_PROD}"
        env.NEXUS_ADDR = "${env.NEXUS_ADDR_PROD}"
    } else {
        env.VAULT_ADDR = "${env.VAULT_ADDR_DEV}"
        env.NEXUS_ADDR = "${env.NEXUS_ADDR_DEV}"
    }

    def VAULT_CONFIGURATION = [
        vaultUrl: "${env.VAULT_ADDR}",
        vaultCredentialId: 'jenkins_approle',
        engineVersion: 2
    ]
    def VAULT_SECRETS = [
        [
            path: "${env.VAULT_PATH}", engineVersion: 2,
            secretValues: [
                [vaultKey: 'db_url'],
                [vaultKey: 'db_username'],
                [vaultKey: 'db_pass']
            ]
        ]
    ]

    withVault([configuration: VAULT_CONFIGURATION, vaultSecrets: VAULT_SECRETS]) {
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: "${env.NEXUS_CRED}", usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD']]) {
            DB_PASS = "${db_pass}"
            DB_CONN = "${db_url}"
            DB_USER = "${db_username}"

            DB_PROPERTIES_FILE = "./liquibase.properties"
            RANDOM_CHANGESET = "${UUID.randomUUID()}"
            stage("Prepare Liquibase") {
                sh """
                    cd ${run_folder}
                    curl -u ${NEXUS_USER}:${NEXUS_PASSWORD} ${env.NEXUS_ADDR}/repository/devsecops/tools/thirdparty/liquibase/liquibase-4.9.0.tar -O
                    tar -xvf liquibase-4.9.0.tar
                    curl -u ${NEXUS_USER}:${NEXUS_PASSWORD} ${env.NEXUS_ADDR}/repository/devsecops/tools/thirdparty/postgresql/jdbcdriver/postgresql-42.3.3.jar -O
                """
            }
            if (env.ACTION == 'ROLLOUT' || env.ACTION == 'ROLLBACK') {
                stage("${env.ACTION.toLowerCase()} DB") {
                    sh """
                        cd ${run_folder}
                        sed -i 's,__CHANGEME__,${LIQUIBASE_PATH}/${env.DEPLOY_ENVIRONMENT}/${env.ACTION.toLowerCase()},g' changelog.yaml
                        cat changelog.yaml
                        ./liquibase update --username="${DB_USER}" --password="${DB_PASS}" --url=${DB_CONN} --defaultsFile=${DB_PROPERTIES_FILE}
                    """
                }
            }
            if (env.ACTION == 'VERIFY') {
                stage("Check DB connection") {
                    sh """
                        cd ${run_folder}
                        sed -i 's,__CHANGEME__,${LIQUIBASE_PATH}/${env.DEPLOY_ENVIRONMENT}/${env.ACTION.toLowerCase()},g' changelog.yaml
                        cat changelog.yaml
                        ./liquibase update --username="${DB_USER}" --password="${DB_PASS}" --url=${DB_CONN} --defaultsFile=${DB_PROPERTIES_FILE} --log-file=output.log
                    """
//                    def output_verify = System.getenv("OUTPUT")
//                    println(output_verify)
                }
            }
        }
    }
    cleanWs()
}
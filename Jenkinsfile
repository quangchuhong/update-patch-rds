node("jenkin-slave-test") {
    parameters {
        string(name: 'STATEMENT', defaultValue: 'hello; ls /', description: 'What should I say?')
    }

    stage('Git Checkout') {
        steps {
                git branch: 'master', url: 'https://github.com/quangchuhong/update-patch-rds.git'
                echo "hello pipeline script node agent"
        }
    }

}
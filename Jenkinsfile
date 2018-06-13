#!groovy

node('worker') {
    checkout scm
    ansiColor('xterm') {
        if(env.BRANCH_NAME == 'master') {
            withAWS(credentials: 'prodAWSCredentials') {
                sh 'make validate_prod'
                sh 'make container'
                sh 'make deploy_prod'
            }
        }
    }
}

#!groovy

node('worker') {
    checkout scm
    ansiColor('xterm') {
        if(env.BRANCH_NAME == 'master') {
            withAWS(credentials: 'prodAWSCredentials') {
                sh 'make deploy ENVIRONMENT=prod'
            }
        }
    }
}

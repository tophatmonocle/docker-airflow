#!groovy

pipeline {
    options {
        timeout(time: 5, unit: 'MINUTES')
        ansiColor('xterm')
    }

    agent {
        dockerfile {
            label 'airflow'
        }
    }

    stages {
        stage('Build') {
            steps {
             sh 'make container_image'
            }
        }

        stage('Publish') {
            when {
                branch 'master'
            }

            steps {
                sh 'make deploy'
            }

        }
    }
}
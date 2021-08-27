pipeline {
    agent {label 'linux' }
    tools {
        nodejs 'node16.8.0'
    }

    stages {

        //stage ('Clone Source Code') {
        //    steps {
        //        git branch: 'main', url: 'https://github.com/calebespinoza/node-web-app'
        //    }
        //}

        stage('install') {
            steps {
                sh "npm install"
            }
        }
        stage('Unit tests') {
            steps {
                sh "npm test"
            }
        }

        stage('Build Image') {
            steps {
                sh "docker build -t nodeapp:$BUILD_NUMBER ."
            }
        }

        stage('Publish Image') {
            steps {
                sh """
                echo "" | docker login -u calebespinoza --password-stdin
                """
            }
            post {
                always {
                    script {
                        sh "docker rmi -f nodeapp:$BUILD_NUMBER"
                        sh "docker logout"
                    }
                }
            }
        }
        
    }
}
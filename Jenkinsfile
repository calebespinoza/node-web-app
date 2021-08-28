pipeline {
    agent {label 'linux' }
    tools {
        nodejs 'node16.8.0'
    }
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials("dockerhub")
        IMAGE_NAME = "nodeapp:$BUILD_NUMBER"
    }

    stages {

        stage('Install') {
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
                sh "docker build -t $IMAGE_NAME ."
            }
        }

        stage('Publish Image') {
            steps {
                sh "echo '$DOCKER_HUB_CREDENTIALS_PSW' | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin"
                sh "docker push $IMAGE_NAME"
            }
            post {
                always {
                    script {
                        sh "docker rmi -f $IMAGE_NAME"
                        sh "docker logout"
                    }
                }
            }
        }
    }
}
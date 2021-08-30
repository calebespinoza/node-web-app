pipeline {
    agent { label 'linux' }

    tools {
        nodejs 'node16.8.0'
    }
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials("dockerhub")
        DOCKER_HUB_REPO = "calebespinoza"
        IMAGE_NAME = "nodeapp"
        IMAGE_TAG_STG = "$BUILD_NUMBER-stg"
        IMAGE_TAG_PROD = "$BUILD_NUMBER-prod"
        FULL_IMAGE_NAME = "$DOCKER_HUB_REPO/$IMAGE_NAME"
    }

    stages {
    // Continuous Integration Pipeline
        stage('Install') {
            steps {
                sh "npm install"
            }
        }

        stage('Unit Tests & Coverage') {
            steps {
                sh "npm test"
            }
        }

        stage('Build Image') {
            when { 
                branch 'main' 
            }
            environment{ 
                TAG = "$IMAGE_TAG_STG"
            }
            steps {
                sh "docker-compose build $IMAGE_NAME"
            }
            post { 
                failure{
                    script {
                        sh "docker rmi \$(docker images --filter dangling=true -q)"
                    }
                }
            }
        }

        stage('Publish Image') {
            when { branch 'main' }
            environment{ TAG = "$IMAGE_TAG_STG" }
            steps {
                sh "echo '$DOCKER_HUB_CREDENTIALS_PSW' | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin"
                sh "docker-compose push $IMAGE_NAME"
            }
            post {
                always {
                    script {
                        sh "docker rmi -f $FULL_IMAGE_NAME:$TAG"
                        sh "docker logout"
                    }
                }
            }
        }
    // End Continuous Integration Pipeline
    }
}
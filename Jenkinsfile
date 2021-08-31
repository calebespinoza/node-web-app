pipeline {
    agent { label 'linux' }

    tools {
        nodejs 'node16.8.0'
    }
    
    environment {
        NEXUS_SERVER_URL = "10.0.2.15:8082"
        DOCKER_HUB_CREDENTIALS = credentials("dockerhub")
        DOCKER_HUB_REPO = "calebespinoza"
        IMAGE_NAME = "nodeapp"
        IMAGE_TAG_STG = "$BUILD_NUMBER-stg"
        IMAGE_TAG_PROD = "$BUILD_NUMBER-prod"
        FULL_IMAGE_NAME = "$DOCKER_HUB_REPO/$IMAGE_NAME"
        PROJECT_NAME = "node-web-app"
        PRIVATE_IMAGE_NAME = "$NEXUS_SERVER_URL/$IMAGE_NAME"
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

        stage ('Static Code Analysis') {
            environment { LCOV_REPORT_PATH = "coverage/lcov.info" }
            steps {
                script {
                    def scannerHome = tool 'sonarscanner4.6.2'
                    def scannerParameters = "-Dsonar.projectName=$PROJECT_NAME " + 
                        "-Dsonar.projectKey=$PROJECT_NAME -Dsonar.sources=. " //+ 
                        //"-Dsonar.javascript.lcov.reportPaths=$LCOV_REPORT_PATH"
                    withSonarQubeEnv('sonarqube-automation') {
                        sh "${scannerHome}/bin/sonar-scanner ${scannerParameters}"
                    }
                }
            }
        }

        stage ('Quality Gate') {
            steps {
                sh "echo 'Quality Gate pending ...'"
            }
        }

        stage('Build Image') {
            //when { 
            //    branch 'main' 
            //}
            environment{ TAG = "$IMAGE_TAG_STG" }
            steps {
                //sh "docker-compose build $IMAGE_NAME"
                sh "docker build -t $PRIVATE_IMAGE_NAME:$TAG"
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
            //when { branch 'main' }
            environment{ 
                TAG = "$IMAGE_TAG_STG"
                NEXUS_CREDENTIALS = credentials("nexus")
            }
            steps {
                //sh "echo '$DOCKER_HUB_CREDENTIALS_PSW' | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin"
                //sh "docker-compose push $IMAGE_NAME"
                sh "echo '$NEXUS_CREDENTIALS_PSW' | docker login -u $NEXUS_CREDENTIALS_USR --password-stdin $NEXUS_SERVER_URL"
                sh "docker push $PRIVATE_IMAGE_NAME:$TAG"
            }
            post {
                always {
                    script {
                        //sh "docker rmi -f $FULL_IMAGE_NAME:$TAG"
                        //sh "docker logout"
                        sh "docker rmi -f $PRIVATE_IMAGE_NAME:$TAG"
                        sh "docker logout $NEXUS_SERVER_URL"
                    }
                }
            }
        }
    // End Continuous Integration Pipeline
    }
}
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
                        "-Dsonar.projectKey=$PROJECT_NAME -Dsonar.sources=. " + 
                        "-Dsonar.javascript.lcov.reportPaths=$LCOV_REPORT_PATH"
                    withSonarQubeEnv('sonarqube-automation') {
                        sh "${scannerHome}/bin/sonar-scanner ${scannerParameters}"
                    }
                }
            }
        }

        stage ('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Image') {
            when { 
                branch 'main' 
            }
            environment{ TAG = "$IMAGE_TAG_STG" }
            steps {
                sh """
                echo 'Building Image for Public Registry (Docker Hub)'
                docker-compose build $IMAGE_NAME
                echo 'Building Image for Private Registry (Nexus)'
                docker build -t $PRIVATE_IMAGE_NAME:$TAG .
                """
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
            environment{ 
                TAG = "$IMAGE_TAG_STG"
                NEXUS_CREDENTIALS = credentials("nexus")
            }
            steps {
                sh """
                echo 'Log into Docker Hub'
                echo '$DOCKER_HUB_CREDENTIALS_PSW' | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin
                echo 'Push image to Docker Hub'
                docker-compose push $IMAGE_NAME
                echo 'Log into Nexus'
                echo '$NEXUS_CREDENTIALS_PSW' | docker login -u $NEXUS_CREDENTIALS_USR --password-stdin $NEXUS_SERVER_URL
                echo "Push image to Nexus"
                docker push $PRIVATE_IMAGE_NAME:$TAG
                """
            }
            post {
                always {
                    script {
                        sh """
                        echo "Removing Image built for Docker Hub"
                        docker rmi -f $FULL_IMAGE_NAME:$TAG
                        echo 'Logout Docker Hub'
                        docker logout
                        echo 'Removing Image built for Nexus'
                        docker rmi -f $PRIVATE_IMAGE_NAME:$TAG
                        echo 'Logout Nexus'
                        docker logout $NEXUS_SERVER_URL
                        """
                    }
                }
            }
        }
    // End Continuous Integration Pipeline

    // Continuous Delivery Pipeline
        stage ('Deploy to Staging') {
            when { branch 'main' }
            environment{ 
                TAG = "$IMAGE_TAG_STG" 
                SERVICE_NAME = "$IMAGE_NAME"
                SERVICES_QUANTITY = "2"
            }
            steps {
                sh "docker-compose up -d --scale $SERVICE_NAME=$SERVICES_QUANTITY --force-recreate"
                sleep 15
            }
        }

        stage ('User Acceptance Tests') {
            when { branch 'main'}
            environment { 
                API_BASE_URL = "http://10.0.2.15"
                PORT_1 = "9090"
                PORT_2 = "9091"
            }
            steps {
                sh "curl -I $API_BASE_URL:$PORT_1 --silent | grep 200"
                sh "curl -I $API_BASE_URL:$PORT_1/atlatam01 --silent | grep 200"
                sh "curl -I $API_BASE_URL:$PORT_2 --silent | grep 200"
                sh "curl -I $API_BASE_URL:$PORT_2/atlatam01 --silent | grep 200"
            }
        }

        stage ('Tag Production Image') {
            when { branch 'main' }
            environment { TAG = "$IMAGE_TAG_PROD" }
            steps {
                sh "docker tag $FULL_IMAGE_NAME:$IMAGE_TAG_STG $FULL_IMAGE_NAME:$IMAGE_TAG_PROD"
                sh "docker tag $FULL_IMAGE_NAME:$IMAGE_TAG_STG $FULL_IMAGE_NAME:latest"
            }
        }

        stage('Deliver Image for Production') {
            when { branch 'main' }
            environment{ 
                NEXUS_CREDENTIALS = credentials("nexus")
            }
            steps {
                sh """
                echo 'Log into Docker Hub'
                echo '$DOCKER_HUB_CREDENTIALS_PSW' | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin
                echo 'Push image to Docker Hub'
                docker push $FULL_IMAGE_NAME:$IMAGE_TAG_PROD
                docker push $FULL_IMAGE_NAME:latest
                """
            }
            post {
                always {
                    script {
                        sh """
                        echo "Removing Image built for Docker Hub"
                        docker rmi -f $FULL_IMAGE_NAME:$IMAGE_TAG_PROD
                        docker rmi -f $FULL_IMAGE_NAME:latest
                        echo 'Logout Docker Hub'
                        docker logout
                        """
                    }
                }
            }
        }
    // End Continuous Delivery Pipeline

    // Continuos Deployment Pipeline
        stage ('Continuous Deployment') {
            when { branch 'main' }
            environment {
                PROD_SERVER = "ubuntu@ec2-18-205-29-252.compute-1.amazonaws.com"
                FOLDER_NAME = "node-web-app"
                SCRIPT = "deployment.sh"
                COMPOSE_FILE = "prod.docker-compose.yaml"
                ENV_FILE = ".env"
            }
            stages {
                stage ('Create .env file') {
                    environment{ TAG = "latest" }
                    steps {
                        sh """
                        echo 'FULL_IMAGE_NAME=$FULL_IMAGE_NAME' > $ENV_FILE
                        echo 'TAG=$TAG' >> $ENV_FILE
                        """
                    }
                }

                stage ('Copy files to Prod Server') {
                    steps {
                        sshagent(['prod-key']) {
                            sh "ssh -o 'StrictHostKeyChecking no' $PROD_SERVER mkdir -p /home/ubuntu/$FOLDER_NAME"
                            sh "scp $ENV_FILE $SCRIPT $COMPOSE_FILE $PROD_SERVER:~/$FOLDER_NAME"
                            sh "ssh -o 'StrictHostKeyChecking no' $PROD_SERVER ls -a /home/ubuntu/$FOLDER_NAME"
                        }
                    }
                }

                stage ('Deploy in Production') {
                    steps {
                        sshagent(['prod-key']) {
                            sh "ssh -o 'StrictHostKeyChecking no' $PROD_SERVER chmod +x /home/ubuntu/$FOLDER_NAME/$SCRIPT"
                            sh "ssh -o 'StrictHostKeyChecking no' $PROD_SERVER $FOLDER_NAME/$SCRIPT '/home/ubuntu/$FOLDER_NAME' '$COMPOSE_FILE'"
                        }
                    }
                }
            }
        }
        
    // End Continuous Deployment Pipeline
    }
}
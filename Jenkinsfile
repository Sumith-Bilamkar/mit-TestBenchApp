pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sumith568/mit-testbenchapp"
        DOCKER_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Go Application') {
            steps {
                script {
                    sh 'go mod tidy'
                    sh 'go build -o mit-TestBenchApp'
                }
            }
        }

        stage('Test Go Application') {
            steps {
                script {
                    sh 'go test ./...'
                }
            }
        }

        stage('Build, Login & Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        """
                    }
                }
            }
        }
    }
}
pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "sumith568/mit-testbenchapp"
        DOCKER_TAG = "latest"
        GO_VERSION = "go-latest" // Using the configured Go installation
    }

    stages {
        stage('Setup Go Environment') {
            steps {
                script {
                    def goPath = tool name: GO_VERSION, type: 'go'
                    env.PATH = "${goPath}/bin:${env.PATH}"
                    sh 'go version' // Verify Go installation
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build, Login & Push Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'dockerhub-credentials']) {
                        sh """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Docker image built and pushed successfully!'
        }
        failure {
            echo '❌ Docker build or push failed!'
        }
        always {
            echo '🧹 Cleaning up workspace...'
            sh 'docker system prune -f'
        }
    }
}
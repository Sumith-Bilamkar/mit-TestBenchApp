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
        stage('Build, Login & Push Docker Image') {
                    steps {
                        script {
                            withDockerRegistry([credentialsId: 'dockerhub-credentials', url: 'https://index.docker.io/v1/']) {
                                sh """
                                docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                                """
                            }
                        }
                    }
                }
    }
}
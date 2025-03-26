pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sumith568/mit-testbenchapp"
        DOCKER_TAG = "latest"
        AWS_REGION = "us-west-2"  // Replace with your AWS region
        EKS_CLUSTER_NAME = "your-eks-cluster"
        NAMESPACE = "your-namespace"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(DOCKER_IMAGE)
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    }
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Update EKS Deployment') {
            steps {
                script {
                    sh """
                    aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}
                    kubectl set image deployment/mit-testbenchapp ${DOCKER_IMAGE}:${DOCKER_TAG} -n ${NAMESPACE}
                    """
                }
            }
        }
    }
}

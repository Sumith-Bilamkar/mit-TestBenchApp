pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "sumith568/mit-testbenchapp"
        DOCKER_TAG = "latest"
        K8S_NAMESPACE = "mit-testbench"
        K8S_DEPLOYMENT_FILE = "deployment-service.yaml"
        AWS_REGION = "us-west-2"
        EKS_CLUSTER_NAME = "mit-acme"
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
                    withDockerRegistry([credentialsId: 'dockerhub-credentials']) {
                        sh """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        """
                    }
                }
            }
        }
        stage('Update kubeconfig') {
            steps {
                script {
                    sh """
                    aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}
                    """
                }
            }
        }
        stage('Create Namespace if not exists') {
            steps {
                script {
                    sh """
                    kubectl get namespace ${K8S_NAMESPACE} || kubectl create namespace ${K8S_NAMESPACE}
                    """
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    kubectl apply -f ${K8S_DEPLOYMENT_FILE} -n ${K8S_NAMESPACE}
                    """
                }
            }
        }
    }
}
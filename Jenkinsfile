pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "sumith568/mit-testbenchapp"
        DOCKER_TAG = "latest"
        K8S_NAMESPACE = "mit-testbench"
        K8S_DEPLOYMENT_FILE = "deployment-service.yaml"
        AWS_REGION = "us-west-2"
        EKS_CLUSTER_NAME = "mit-acme"
        ARTIFACTS_DIR = "artifacts"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Security Scan - Dependency-Check') {
            steps {
                script {
                    sh 'mkdir -p dependency-check-reports' // Ensure report directory exists
                }
                dependencyCheck format: ['HTML', 'JSON'], // Generate reports in both formats
                                outdir: 'dependency-check-reports',
                                failBuildOnCVSS: 7.0, // Optional threshold for CVSS
                                data: 'dependency-check-data',
                                suppressionFile: ''
            }
        }

        stage('Save Security Scan Reports') {
            steps {
                script {
                    sh 'mkdir -p artifacts'
                    sh 'cp dependency-check-reports/dependency-check-report.html artifacts/'
                    sh 'cp dependency-check-reports/dependency-check-report.json artifacts/'
                }
                archiveArtifacts artifacts: 'artifacts/dependency-check-report.*', allowEmptyArchive: true
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
    post {
        success {
            echo 'Deployment was successful!'
            archiveArtifacts artifacts: '**/*.yaml', allowEmptyArchive: true
            sh """
                mkdir -p artifacts
                kubectl get all -n ${K8S_NAMESPACE} > artifacts/k8s-resources.log || echo "No resources found" > artifacts/k8s-resources.log
            """
            archiveArtifacts artifacts: '${ARTIFACTS_DIR}/*', allowEmptyArchive: true
            fingerprint 'artifacts/k8s-resources.log'
        }
        failure {
            echo 'Build or deployment failed!'
        }
        always {
            echo 'Cleaning up workspace...'
            sh 'docker system prune -f'
        }
    }
}
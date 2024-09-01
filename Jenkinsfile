pipeline {
    agent any

    environment {
        DOCKER_REPO = 'mrdhanz/react-app'
        KUBE_CONFIG = credentials('kubeconfig') // Jenkins credentials for Kubernetes config
    }

    stages {
        stage('Checkout Code') {
            steps {
                git credentialsId: 'Git', url: 'https://github.com/mrdhanz/react-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                     docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        docker.image('docker:latest').inside('-v /var/run/docker.sock:/var/run/docker.sock') {
                            sh "docker build -t ${DOCKER_REPO}:latest ."
                        }
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        docker.image('docker:latest').inside('-v /var/run/docker.sock:/var/run/docker.sock') {
                            sh "docker push ${DOCKER_REPO}:latest"
                        }
                    }
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                script {
                    sh """
                        terraform init
                        terraform apply -auto-approve
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

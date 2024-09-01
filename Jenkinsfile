pipeline {
    agent any

    environment {
        KUBE_CONFIG = credentials('kubeconfig') // Jenkins credentials ID for Kubeconfig
        TERRAFORM_WORKSPACE = 'default'
        REACT_APP_NAME = 'my-react-app'
        NAMESPACE = 'default'
    }

    tools {
        nodejs 'nodejs-22'
        terraform 'terraform'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/mrdhanz/react-app.git', credentialsId: 'Git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

        // copy the kubeconfig file to /var/jenkins_home/.kube/config
        stage('Prepare Kubeconfig') {
            steps {
                sh '''
                mkdir -p /var/jenkins_home/.kube
                cp $KUBE_CONFIG /var/jenkins_home/.kube/config
                '''
            }
        }

        stage('Apply Terraform') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    terraform init
                    terraform workspace select $TERRAFORM_WORKSPACE
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl apply -f kubernetes/deployment.yaml
                    kubectl apply -f kubernetes/service.yaml
                    '''
                }
            }
        }
    }
}
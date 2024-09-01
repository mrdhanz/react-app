pipeline {
    agent any

    environment {
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

         stage('Apply Terraform') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    terraform init
                    terraform workspace select $TERRAFORM_WORKSPACE
                    terraform apply -auto-approve -var="kubeconfig=$KUBECONFIG"
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl --kubeconfig=$KUBECONFIG apply -f kubernetes/deployment.yaml
                    kubectl --kubeconfig=$KUBECONFIG apply -f kubernetes/service.yaml
                    '''
                }
            }
        }
    }
}
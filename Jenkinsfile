pipeline {
    agent any
    // add terraform destroy parameter
    parameters {
        booleanParam(defaultValue: false, description: 'Destroy the infrastructure', name: 'DESTROY')
    }

    environment {
        KUBE_CONFIG = credentials('kubeconfig') // Jenkins credentials ID for Kubeconfig
        TERRAFORM_WORKSPACE = 'default'
        REACT_APP_NAME = 'react-app'
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
            when {
                expression { return !params.DESTROY }
            }
            steps {
                sh 'npm install'
            }
        }

        stage('Build React App') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                sh 'npm run build'
            }
        }

        stage('Apply Terraform') {
            when {
                expression { return !params.DESTROY }
            }
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
            when {
                expression { return !params.DESTROY }
            }
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl apply -f kubernetes/deployment.yaml
                    kubectl apply -f kubernetes/service.yaml
                    # Wait for the pod to be ready
                    POD_NAME=""
                    while [ -z "$POD_NAME" ]; do
                        POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=$REACT_APP_NAME -o jsonpath="{.items[0].metadata.name}" --field-selector=status.phase=Running)
                        sleep 2
                    done
                    echo "Pod is running: $POD_NAME"
                    # Copy the build folder to the pod
                    kubectl cp build/ $POD_NAME:/usr/share/nginx/html -n $NAMESPACE
                    '''
                }
            }
        }

        stage('Destroy Kubernetes Resources') {
            when {
                expression { return params.DESTROY }
            }
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl delete -f kubernetes/service.yaml
                    kubectl delete -f kubernetes/deployment.yaml
                    '''
                }
            }
        }

        stage('Destroy Terraform') {
            when {
                expression { return params.DESTROY }
            }
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    terraform init
                    terraform workspace select $TERRAFORM_WORKSPACE
                    terraform destroy -auto-approve
                    '''
                }
            }
        }
    }
}

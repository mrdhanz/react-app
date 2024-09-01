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

        stage('Apply Terraform Plan') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    terraform init
                    terraform workspace select $TERRAFORM_WORKSPACE
                    terraform apply -auto-approve
                    # Copy build result to the PVC volume in the pod
                    POD_NAME=$(kubectl get pods -n $REACT_APP_NAME -l app=$REACT_APP_NAME -o jsonpath="{.items[0].metadata.name}")
                    kubectl cp build $POD_NAME:/usr/share/nginx/html -n $REACT_APP_NAME
                    kubectl exec $POD_NAME -n $REACT_APP_NAME -- sh -c 'mv /usr/share/nginx/html/build/* /usr/share/nginx/html/'
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

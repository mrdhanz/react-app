pipeline {
    agent any
    parameters {
        booleanParam(defaultValue: false, description: 'Destroy the infrastructure', name: 'DESTROY')
    }

    environment {
        KUBE_CONFIG = credentials('kubeconfig')
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

        stage('Build React App for each environment') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                script {
                    def envDirectory = 'environment'
                    def envFiles = findFiles(glob: "${envDirectory}/.env.*")

                    if (envFiles.length == 0) {
                        error "No .env files found in ${envDirectory}"
                    }

                    sh 'npm install -g env-cmd'

                    envFiles.each { envFile ->
                        def envName = envFile.name.replace('.env.', '')
                        echo "Building for environment: ${envName}"
                        withEnv(["ENV_FILE=${envFile.path}"]) {
                            echo "Running build for ${envName} using ${envFile.path}"
                            sh "env-cmd -f ${envFile.path} npm run build"
                            sh "rm -rf build-${envName}"
                            sh "mv build build-${envName}"
                        }
                    }
                }
            }
        }

        stage('Apply Terraform Plan') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                script {
                    def envDirectory = 'environment'
                    def envFiles = findFiles(glob: "${envDirectory}/.env.*")

                    if (envFiles.length == 0) {
                        error "No .env files found in ${envDirectory}"
                    }

                    sh "terraform init"

                    envFiles.each { envFile ->
                        def envName = envFile.name.replace('.env.', '')
                        echo "Applying Terraform for environment: ${envName}"
                        def tfvarsFile = "${envDirectory}/${envName}.tfvars"

                        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                            sh """
                            terraform workspace select $TERRAFORM_WORKSPACE
                            terraform apply -auto-approve -var-file=${tfvarsFile}
                            kubectl wait --for=condition=ready pod -l app=${REACT_APP_NAME} -n ${REACT_APP_NAME}-${envName} --timeout=300s
                            POD_NAME=\$(kubectl get pods -n ${REACT_APP_NAME}-${envName} -l app=${REACT_APP_NAME} -o jsonpath='{.items[0].metadata.name}')
                            kubectl cp build-${envName} \$POD_NAME:/usr/share/nginx/html -n ${REACT_APP_NAME}-${envName}
                            kubectl exec \$POD_NAME -n ${REACT_APP_NAME}-${envName} -- sh -c 'mv /usr/share/nginx/html/build-${envName}/* /usr/share/nginx/html/'
                            """
                        }
                    }
                }
            }
        }


        stage('Destroy Terraform') {
            when {
                expression { return params.DESTROY }
            }
            steps {
                script {
                    def envDirectory = 'environment'
                    def envFiles = findFiles(glob: "${envDirectory}/.env.*")

                    if (envFiles.length == 0) {
                        error "No .env files found in ${envDirectory}"
                    }

                    envFiles.each { envFile ->
                        def envName = envFile.name.replace('.env.', '')
                        echo "Destroying Terraform for environment: ${envName}"
                        def tfvarsFile = "${envDirectory}/${envName}.tfvars"

                        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                            sh """
                            terraform workspace select $TERRAFORM_WORKSPACE
                            terraform destroy -auto-approve -var-file=${tfvarsFile}
                            """
                        }
                    }
                }
            }
        }
    }
}

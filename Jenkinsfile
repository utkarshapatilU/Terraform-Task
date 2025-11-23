pipeline {
    agent any

    environment {
        TERRAFORM_BIN = "${WORKSPACE}/infra/bin/terraform"
        AWS_DEFAULT_REGION = "ap-south-1"
        PATH = "${env.PATH}:${WORKSPACE}/infra/bin"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                echo "Cloning repository..."
                git branch: 'main',
                    url: 'https://github.com/utkarshapatilU/Terraform-Task.git',
                    credentialsId: 'github-creds'
            }
        }

        stage("Install Terraform") {
            steps {
                sh '''
                    set -x
                    set -e

                    # Ensure we're in the workspace root
                    cd ${WORKSPACE}

                    # Remove old terraform binary directory if exists
                    rm -rf infra/bin

                    echo "Downloading Terraform..."
                    wget -q https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip

                    echo "Extracting Terraform..."
                    unzip -o terraform_1.9.8_linux_amd64.zip

                    # Create directory and move terraform binary
                    mkdir -p infra/bin
                    mv terraform infra/bin/terraform
                    chmod +x infra/bin/terraform

                    # Clean up zip file
                    rm -f terraform_1.9.8_linux_amd64.zip LICENSE.txt

                    # Verify terraform is installed
                    ${WORKSPACE}/infra/bin/terraform version
                '''
            }
        }

        stage("Terraform Init") {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
                        export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
                        cd infra/terraform-bin
                        ${TERRAFORM_BIN} init
                    '''
                }
            }
        }

        stage("Terraform Validate") {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
                        export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
                        cd infra/terraform-bin
                        ${TERRAFORM_BIN} validate
                    '''
                }
            }
        }

        stage("Terraform Plan") {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
                        export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
                        cd infra/terraform-bin
                        ${TERRAFORM_BIN} plan
                    '''
                }
            }
        }

        stage("Terraform Apply") {
            when {
                branch "main"
            }
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
                        export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
                        cd infra/terraform-bin
                        ${TERRAFORM_BIN} apply -auto-approve
                    '''
                }
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed! Check the logs."
        }
        success {
            echo "Pipeline completed successfully!"
        }
    }
}


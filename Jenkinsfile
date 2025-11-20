pipeline {
    agent any

    environment {
        TERRAFORM_BIN = "${WORKSPACE}/terraform-bin"
        PATH = "${env.PATH}:${WORKSPACE}"
        SSH_KEY_PATH = "${WORKSPACE}/terraform/keys/devops_key.pub"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/utkarshapatilU/Terraform-Task.git',
                        credentialsId: 'github-creds'
                    ]]
                ])
            }
        }

        stage('Download Terraform (Local Install)') {
            steps {
                sh '''
                    echo "Downloading Terraform..."
                    wget -q https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
                    echo "Unzipping..."
                    unzip -o terraform_1.9.8_linux_amd64.zip
                    echo "Renaming binary..."
                    mv terraform terraform-bin
                    chmod +x terraform-bin
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    echo "Initializing Terraform..."
                    ${TERRAFORM_BIN} init || exit 1
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                    echo "Validating Terraform..."
                    if [ ! -f "${SSH_KEY_PATH}" ]; then
                        echo "ERROR: SSH public key not found at ${SSH_KEY_PATH}"
                        exit 1
                    fi
                    ${TERRAFORM_BIN} validate || exit 1
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    echo "Terraform Plan..."
                    ${TERRAFORM_BIN} plan -var "public_key_path=${SSH_KEY_PATH}" || exit 1
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    echo "Applying Terraform..."
                    ${TERRAFORM_BIN} apply -auto-approve -var "public_key_path=${SSH_KEY_PATH}" || exit 1
                '''
            }
        }
    }

    post {
        success {
            echo "Terraform pipeline completed successfully!"
        }
        failure {
            echo "Terraform pipeline failed!"
        }
    }
}

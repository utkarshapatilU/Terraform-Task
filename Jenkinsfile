pipeline {
    agent any

    environment {
        TERRAFORM_BIN = "${WORKSPACE}/terraform/terraform-bin"
        SSH_PRIVATE_KEY = "${WORKSPACE}/terraform/keys/devops_key" 
        PATH = "${env.PATH}:${WORKSPACE}"
        
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION = 'ap-south-1'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo "Cloning repository..."
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/utkarshapatilU/Terraform-Task.git',
                        credentialsId: 'github-creds'
                    ]]
                ])
            }
        }

        stage('Download Terraform') {
            steps {
                echo "Downloading Terraform..."
                sh '''
                    set -x
                    wget -q https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
                    unzip -o terraform_1.9.8_linux_amd64.zip
                    mv terraform ${TERRAFORM_BIN}
                    chmod +x ${TERRAFORM_BIN}
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                echo "Initializing Terraform..."
                sh '''
                    set -x
                    ${TERRAFORM_BIN} init || exit 1
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                echo "Validating Terraform configuration..."
                sh '''
                    set -x
                    if [ ! -f "${SSH_PRIVATE_KEY}" ]; then
                        echo "ERROR: SSH private key not found at ${SSH_PRIVATE_KEY}"
                        exit 1
                    fi
                    ${TERRAFORM_BIN} validate || exit 1
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "Creating Terraform plan..."
                sh '''
                    set -x
                    ${TERRAFORM_BIN} plan -var "private_key_path=${SSH_PRIVATE_KEY}" || exit 1
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                echo "Applying Terraform..."
                sh '''
                    set -x
                    ${TERRAFORM_BIN} apply -auto-approve -var "private_key_path=${SSH_PRIVATE_KEY}" || exit 1
                '''
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                echo "Generating dynamic Ansible inventory from Terraform output..."
                sh '''
                    set -x
                    ${TERRAFORM_BIN} output -json > tf-output.json
                    python3 scripts/generate_inventory.py tf-output.json inventory.ini
                '''
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                echo "Running Ansible playbook..."
                sh '''
                    set -x
                    ansible-playbook -i inventory.ini deploy.yml --private-key=${SSH_PRIVATE_KEY} --extra-vars "ansible_user=ubuntu"
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed! Check the console logs for errors."
        }
    }
}

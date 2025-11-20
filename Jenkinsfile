pipeline {
    agent any

    environment {
        TERRAFORM_VERSION = "1.9.8"
        TF_BIN = "${WORKSPACE}/terraform-bin"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/utkarshapatilU/Terraform-Task.git'
            }
        }

        stage('Download Terraform (Local Install)') {
            steps {
                sh '''
                    echo "Downloading Terraform..."
                    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

                    echo "Unzipping..."
                    unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip

                    echo "Renaming binary..."
                    mv terraform terraform-bin
                    chmod +x terraform-bin
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    export PATH=$PATH:${WORKSPACE}
                    cd terraform
                    ${TF_BIN} init
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                    export PATH=$PATH:${WORKSPACE}
                    cd terraform
                    ${TF_BIN} validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    export PATH=$PATH:${WORKSPACE}
                    cd terraform
                    ${TF_BIN} plan
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    export PATH=$PATH:${WORKSPACE}
                    cd terraform
                    ${TF_BIN} apply -auto-approve
                '''
            }
        }
    }

    post {
        failure {
            echo "Terraform pipeline failed!"
        }
        success {
            echo "Terraform pipeline executed successfully!"
        }
    }
}

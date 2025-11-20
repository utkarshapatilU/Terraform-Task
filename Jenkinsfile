pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = "true"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/utkarshapatilU/Terraform-Task.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform --version'
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return params.APPLY == true }
            }
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
    }

    post {
        success {
            echo "Terraform pipeline executed successfully!"
        }
        failure {
            echo "Terraform pipeline failed!"
        }
    }
}

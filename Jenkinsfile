pipeline {
    agent any

    environment {
        AZURE_CLIENT_ID     = credentials('azure-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')
        AZURE_TENANT_ID     = credentials('azure-tenant-id')
    }

    parameters {
        choice(
            name: 'Environment',
            choices: ['dev', 'prod'],
            description: 'Select the environment to deploy'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Azure Deployment') {
            steps {
                dir('scripts') {
                    echo "Running deployment script..."
                    pwsh """
                        ./deploy.ps1 -Environment ${params.Environment}
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment succeeded.'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}

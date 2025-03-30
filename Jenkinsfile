pipeline {
    agent any

    environment {
        AZURE_CLIENT_ID     = credentials('azure-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')
        AZURE_TENANT_ID     = credentials('azure-tenant-id')
    }

    parameters {
        choice(name: 'Environment', choices: ['dev', 'prod'], description: 'Choose environment to deploy')
    }

    stages {
        stage('Azure Deployment') {
            steps {
                dir('scripts') {
                    pwsh '''
                        ./deploy.ps1 -Environment ${env.Environment}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Deployment succeeded."
        }
        failure {
            echo "Deployment failed."
        }
    }
}

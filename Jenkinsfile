pipeline {
    agent any

    environment {
        ACR_NAME             = 'kubernetesacr04082003'
        ACR_LOGIN_SERVER     = 'kubernetesacr04082003.azurecr.io'
        IMAGE_NAME           = 'kubernetes04082003'
        RESOURCE_GROUP       = 'rg-aks-acr'
        AKS_CLUSTER          = 'mycluster04082003'
        AZURE_CREDENTIALS_ID = 'azure-service-principal-kubernetes'
        AZURE_CLI_PATH       = 'C:/Program Files/Microsoft SDKs/Azure/CLI2/wbin'
        SYSTEM_PATH          = 'C:/Windows/System32'
        TERRAFORM_PATH       = 'C:/Users/window 10/Downloads/terraform_1.11.3_windows_386'
    }

    stages {

        stage('Azure Login') {
            steps {
                bat 'az login --service-principal -u 548e5e7d-b2db-4ffd-822e-46a0a4191a11 -p SF18Q~XoFKH2-dRajJGgdSvj-6Ko48roAl7_qaUU --tenant ccb92876-d4ba-4bc7-b967-c9177170db6d'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    withCredentials([azureServicePrincipal(
                        credentialsId: AZURE_CREDENTIALS_ID,
                        subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID',
                        clientIdVariable: 'ARM_CLIENT_ID',
                        clientSecretVariable: 'ARM_CLIENT_SECRET',
                        tenantIdVariable: 'ARM_TENANT_ID'
                    )]) {
                        bat '''
                            set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                            set ARM_SUBSCRIPTION_ID=%ARM_SUBSCRIPTION_ID%
                            set ARM_CLIENT_ID=%ARM_CLIENT_ID%
                            set ARM_CLIENT_SECRET=%ARM_CLIENT_SECRET%
                            set ARM_TENANT_ID=%ARM_TENANT_ID%
                            terraform init
                            terraform plan
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Login to ACR') {
            steps {
                bat '''
                    set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                    az acr login --name %ACR_NAME%
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                    set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                    docker build -t %ACR_LOGIN_SERVER%/%IMAGE_NAME%:latest .
                '''
            }
        }

        stage('Push Image to ACR') {
            steps {
                bat '''
                    set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                    docker push %ACR_LOGIN_SERVER%/%IMAGE_NAME%:latest
                '''
            }
        }

        stage('Get AKS Credentials') {
            steps {
                bat '''
                    set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                    az aks get-credentials --resource-group %RESOURCE_GROUP% --name %AKS_CLUSTER% --overwrite-existing
                '''
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat '''
                    set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                    kubectl apply -f deployment.yml
                '''
            }
        }
    }
}

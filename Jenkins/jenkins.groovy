pipeline {
    agent any

    environment {
        // Path to your kubeconfig (from the bastion golden image)
        KUBECONFIG = '/home/ubuntu/.kube/config'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/yourusername/eks-devops-pipeline.git', credentialsId: 'github-creds-id'
            }
        }

        stage('Install dependencies') {
            steps {
                sh '''
                    # Update system
                    sudo apt update -y

                    # Ensure ansible and helm are installed
                    sudo apt install -y ansible curl unzip
                    curl -LO https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz
                    tar -zxvf helm-v3.12.0-linux-amd64.tar.gz
                    sudo mv linux-amd64/helm /usr/local/bin/helm
                '''
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                sh '''
                    # Make sure the ansible playbook is executable
                    ansible-playbook -i inventory.ini playbooks/deploy-nginx.yaml
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}

pipeline {
    agent any

    environment {
        KUBECONFIG = '/home/ubuntu/.kube/config'
    }

    stages {
        stage('Checkout') {
            steps {
                // This will clone repo into Jenkins workspace
                git branch: 'master', url: 'https://github.com/2402199/EKS-DEVOPS-MASTER.git', credentialsId: 'GIT_JERRY'

                // Optional: Copy repo contents to /home/ubuntu if needed
                sh '''
                    rm -rf /home/ubuntu/EKS-DEVOPS-MASTER
                    cp -r $WORKSPACE /home/ubuntu/EKS-DEVOPS-MASTER
                '''
            }
        }

        stage('Install dependencies') {
            steps {
                sh '''
                    sudo apt update -y
                    sudo apt install -y ansible curl unzip

                    curl -LO https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz
                    tar -zxvf helm-v3.12.0-linux-amd64.tar.gz
                    sudo mv linux-amd64/helm /usr/local/bin/helm
                '''
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('/home/ubuntu/EKS-DEVOPS-MASTER') {
                    sh '''
                        cd EKS-DEVOPS-MASTER
                        cd Ansible
                        ansible-playbook -i inventory.ini install-argoCD.yaml

                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}

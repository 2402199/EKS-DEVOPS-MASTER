pipeline {
  agent any

  environment {
    AWS_REGION      = "ap-south-1"
    CLUSTER_NAME    = "EKS-Test"
    KUBECONFIG_FILE = "${WORKSPACE}/kubeconfig"
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'master',
            url: 'https://github.com/2402199/EKS-DEVOPS-MASTER.git',
            credentialsId: 'GIT_JERRY'
      }
    }

    stage('Prepare AWS creds & update kubeconfig') {
      steps {
         {
          sh '''
          #!/bin/bash
          ls
          
          pwd

          '''
        }
      }
    }
  }

  post {
    always {
      echo "✅ Pipeline finished. Kubeconfig saved at: ${env.WORKSPACE}/kubeconfig"
    }
  }
}

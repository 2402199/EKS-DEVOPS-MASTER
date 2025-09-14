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
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_CRED']]) {
          sh '''#!/bin/bash
          set -euo pipefail

          echo "Updating kubeconfig for cluster: ${CLUSTER_NAME} in ${AWS_REGION}"

          # Write kubeconfig into workspace (isolated from host)
          aws eks --region "${AWS_REGION}" update-kubeconfig \
              --name "${CLUSTER_NAME}" \
              --kubeconfig "${KUBECONFIG_FILE}"

          chmod 600 "${KUBECONFIG_FILE}"

          echo "Verifying access to cluster..."
          KUBECONFIG="${KUBECONFIG_FILE}" kubectl get nodes --no-headers || echo "⚠️ Could not list nodes, check IAM or cluster state."
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

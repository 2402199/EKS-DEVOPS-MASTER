pipeline {
  agent any

  environment {
    AWS_REGION   = "ap-south-1"
    CLUSTER_NAME = "EKS-Test"
    KUBECONFIG_FILE = "${WORKSPACE}/kubeconfig"
  }

  stages {
    stage('Checkout') {
      steps {
        // clone the repo into the workspace
        git branch: 'master',
            url: 'https://github.com/2402199/EKS-DEVOPS-MASTER.git',
            credentialsId: 'GIT_JERRY'
      }
    }

    stage('Prepare AWS creds & update kubeconfig') {
      steps {
        // This uses the AWS Credentials Binding plugin to expose AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
        // If your Jenkins does not have this binding, see the alternative at the bottom.
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_CRED']]) {
          sh '''
            set -euo pipefail


            # Create/overwrite kubeconfig in workspace (does not touch host kubeconfig)
            export AWS_REGION=${AWS_REGION}
            aws eks --region "${AWS_REGION}" update-kubeconfig --name "${CLUSTER_NAME}" --kubeconfig "${KUBECONFIG_FILE}"

            # Lock down kubeconfig file permissions
            chmod 600 "${KUBECONFIG_FILE}"

            # Quick verification (non-failing if cluster access fails)
            echo "Verifying access to cluster (kubectl get nodes):"
            KUBECONFIG="${KUBECONFIG_FILE}" kubectl get nodes --no-headers || echo "Warning: could not list nodes (check IAM permissions / cluster name / region)."
          '''
        }
      }
    }
  }

  post {
    always {
      echo "Pipeline finished. Kubeconfig is at: ${env.WORKSPACE}/kubeconfig"
    }
  }
}

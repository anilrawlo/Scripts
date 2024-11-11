pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prod'], description: 'Select the environment to deploy to')
    }

    environment {
        TEMP_DIR = '/tmp/pyforge'
        BACKUP_DIR = '/tmp/backup/pyforge-$(date +%Y%m%d%H%M%S).tar.gz'
        EXCLUDE_DIR = 'sub-directory-to-exclude' // specify the name of the subdirectory to exclude
    }

    stages {
        stage('Backup and Update') {
            steps {
                script {
                    // Set environment specific variables
                    def serverAddress = ''
                    def credentialsId = ''
                    if (params.ENVIRONMENT == 'dev') {
                        serverAddress = 'dev-server-address'
                        credentialsId = 'matlab_dev' // Using the global credential ID for dev environment
                    } else if (params.ENVIRONMENT == 'prod') {
                        serverAddress = 'prod-server-address'
                        credentialsId = 'matlab_prod' // Using the global credential ID for prod environment
                    }

                    // Connect to the selected server (dev or prod)
                    withCredentials([sshUserPrivateKey(credentialsId: credentialsId, keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                        sh """
                            ssh -i ${SSH_KEY} ${SSH_USER}@${serverAddress} '
                                # Create a backup of the current target directory, excluding the large sub-directory
                                tar --exclude="/opt/matlab/pyforge/${EXCLUDE_DIR}" -czf ${BACKUP_DIR} -C /opt/matlab pyforge

                                # Pull the latest changes into the temporary directory
                                cd ${TEMP_DIR} && git pull origin main

                                # Copy the updated files to the target directory
                                cp -r ${TEMP_DIR}/* /opt/matlab/pyforge/
                            '
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Deployment completed for the ${params.ENVIRONMENT} environment."
        }
    }
}
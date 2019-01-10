pipeline {
  agent any
  stages {
    stage('Container Build') {
      parallel {
        stage('Container Build') {
          steps {
            echo 'Building..'
          }
        }
        stage('Building tng-dpolicy-mngr') {
          steps {
            sh 'docker build -t registry.sonata-nfv.eu:5000/tng-dpolicy-mngr:v4.0 .'
          }
        }
        stage('Building son-nexus') {
          steps {
            sh 'docker build -t registry.sonata-nfv.eu:5000/son-nexus -f nexus/Dockerfile .'
          }
        }
      }
    }
    stage('Containers Publication') {
      parallel {
        stage('Containers Publication') {
          steps {
            echo 'Publication of containers in local registry....'
          }
        }
        stage('Publishing tng-dpolicy-mngr') {
          steps {
            sh 'docker push registry.sonata-nfv.eu:5000/tng-dpolicy-mngr:v4.0'
          }
        }
        stage('Publishing son-nexus') {
          steps {
            sh 'docker push registry.sonata-nfv.eu:5000/son-nexus'
          }
        }
      }
    }
    stage('Deployment in Integration') {
      parallel {
        stage('Deployment in Integration') {
          steps {
            echo 'Deploying in integration...'
          }
        }
        stage('Deploying') {
          steps {
            sh 'rm -rf tng-devops || true'
            sh 'git clone https://github.com/sonata-nfv/tng-devops.git'
            dir(path: 'tng-devops') {
              sh 'ansible-playbook roles/sp.yml -i environments -e "target=int-sp  component=policy-manager"'
            }
            
          }
        }
      }
    }
  }
}
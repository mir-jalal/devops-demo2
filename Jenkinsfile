#!/usr/bin/env groovy

pipeline{
  environment {
    registryDb = '/petclinic-db'
    registryApp = '/petclinic-app'
    registryIp = '34.123.224.226:5000'
    registryUrl = "https://$registryIp"
    registryCredentialsId = 'e1089ec1-6375-4f6a-97b1-998d5526ce2d'

    dbTag = 'petclinic-db'
    dbDir = './docker-db'

    buildTag = 'petclinic-app:alpha'
    buildDir = './build'

    appTag = 'petclinic-app:latest'
    appDir = './app'
  }

  agent {
    node {
      label "host"
    }
  }

  stages{
    stage('Build DB image'){
      steps{
        sh("docker build -t ${dbTag} ${dbDir}")
      }
    }

    stage('Run DB container'){
      steps{
        script {
          withCredentials([file(credentialsId: 'secret-env', variable: 'FILE')]) {
            try {
              sh("docker rm -f petclinic-db")
            }catch(ignored){
              echo "Error occurred: skipping"
            }
            sh("docker run \
                --name petclinic-db \
                --expose 3306 \
                -p 3306:3306 \
                --env-file ${FILE} \
                --volume ${HOME}/db:/var/lib/mysql \
                -d \
                petclinic-db")
          }
        }
      }
    }
    stage('Tag and Push DB image to Registry'){
      steps{
        script {
          docker.withRegistry(registryUrl, registryCredentialsId) {
            sh("docker tag ${dbTag}:latest ${registryIp + registryDb + ":$BUILD_NUMBER"}")
            sh("docker push ${registryIp + registryDb + ":$BUILD_NUMBER"}")
          }
        }
      }
    }

    stage('Build App builder image'){
      steps{
        sh("docker build -t ${buildTag} ${buildDir}")
      }
    }

    stage('Run App builder container'){
      steps{
        script {
          withCredentials([file(credentialsId: 'secret-env', variable: 'FILE')]) {
            sh("docker run \
                --name petclinic-builder \
                --env-file ${FILE} \
                --env BUILD_BRANCH=main \
                --volume ${WORKSPACE}/app/target:/spring-petclinic/target \
                --volume ${HOME}/docker/m2:/root/.m2 \
                --volume ${WORKSPACE}/build/entrypoint.sh:/startup.sh \
                --rm \
                petclinic-app:alpha")
          }
        }
      }
    }

    stage('Build App runner image'){
      steps{
        sh("docker build -t ${appTag} ${appDir}")
      }
    }

    stage('Run App runner container'){
      steps{
        script {
          withCredentials([file(credentialsId: 'secret-env', variable: 'FILE')]) {
            try {
              sh("docker rm -f petclinic-app")
            }catch(ignored){
              echo "Error occurred: skipping"
            }
            sh("docker run \
                --name petclinic-app \
                --expose 8080 \
                -p 8089:8080 \
                --env-file ${FILE} \
                --restart=on-failure \
                -d \
                petclinic-app:latest")
          }
        }
      }
    }

    stage('Tag and Push App image to Registry'){
      steps {
        script {
          docker.withRegistry(registryUrl, registryCredentialsId) {
            sh("docker tag ${appTag} ${registryIp + registryApp + ":$BUILD_NUMBER"}")
            sh("docker push ${registryIp + registryApp + ":$BUILD_NUMBER"}")
          }
        }
      }
    }
  }
}

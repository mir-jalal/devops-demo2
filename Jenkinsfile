#!/usr/bin/env groovy

pipeline{
  environment {
    registryDb = '/petclinic-db'
    registryApp = '/petclinic-app'
    registryIp = '34.123.224.226:5000'
    registryUrl = "https://$registryIp"
    registryCredentialsId = 'e1089ec1-6375-4f6a-97b1-998d5526ce2d'
  }

  agent any

  stages{
    stage('Build and Push DB image'){
      steps{
        script{
          docker.withRegistry(registryUrl, registryCredentialsId){
            sh("docker build -t ${registryIp + registryDb + ":$BUILD_NUMBER" + ' ./docker-db '}")
            sh("docker push ${registryIp + registryDb + ":$BUILD_NUMBER"}")
          }
        }
      }
    }

    stage('Build and Push App image'){
      steps{
        script{
          docker.withRegistry(registryUrl, registryCredentialsId){
            sh("docker build -t $registryIp$registryApp:$BUILD_NUMBER ./docker-app ")
            sh("docker push $registryIp$registryApp:$BUILD_NUMBER")
          }
        }
      }
    }
  }
}

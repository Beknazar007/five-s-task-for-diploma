// stages:
//   - build
//   - push

// variables:
//   ECR_REGISTRY: $ECR_REGISTRY
//   IMAGE_NAME: backend
//   AWS_REGION: us-east-1
//   AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
//   AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY

// build:
//   stage: build
//   image: docker:latest
//   services:
//     - docker:dind
//   script:
//     - docker build -t $IMAGE_NAME .
//     - echo "Docker build completed."

// push:
//   stage: push
//   image: python:3.9
//   before_script:
//     - apt-get update
//     - apt-get install -y python3-pip
//     - pip3 install awscli
//   script:
//     - $(aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY)
//     - docker tag $IMAGE_NAME:latest $ECR_REGISTRY/$IMAGE_NAME:latest
//     - docker push $ECR_REGISTRY/$IMAGE_NAME:latest

// after_script:
//   - docker logout $ECR_REGISTRY


pipeline {
    agent any
    
    environment {
        ECR_REGISTRY = credentials('nurbolot01') // Use the ID of the credentials you created
        IMAGE_NAME = 'backend'
        AWS_REGION = 'us-east-1'
    }
    stages {
        stage('Build') {
            steps {
                script {
                    dir('backend-awesome-cats') {
                        sh 'docker build -t $IMAGE_NAME -f backend-awesome-cats/Dockerfile .'
                    }
                }
                echo 'Docker build completed.'
            }
        }
        stage('Push') {
            steps {
                script {
                    sh "docker login -u AWS -p \$(aws ecr get-login-password --region $AWS_REGION) $ECR_REGISTRY"
                    sh "docker tag $IMAGE_NAME:latest $ECR_REGISTRY/$IMAGE_NAME:latest"
                    sh "docker push $ECR_REGISTRY/$IMAGE_NAME:latest"
                }
            }
        }
    }
    post {
        always {
            sh "docker logout $ECR_REGISTRY"
        }
    }
}



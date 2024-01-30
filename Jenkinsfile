pipeline {
    agent any

    // environment variable setting
    environment {
      JENKINS_SERVER_JAR = '/var/lib/jenkins/workspace/JenkinsTest2_dev/target/JenkinsTest.jar'

      DEV_SERVER_PORT = '8080'
      DOCKER_IMAGE_NAME = 'akkessun/jenkins-test'
      DOCKER_CONTAINER_NAME = 'jenkinsTest'

      LAST_COMMIT = ""
      TODAY= java.time.LocalDate.now()
    }

    stages {
      stage('[Dev] Jenkins variable setting'){
        when {
          branch 'dev'
        }
        steps {
          script {
              // ------ use Folder Property plugin
              // Jenkins variable setting
              wrap([$class: 'ParentFolderBuildWrapper']) {
                  host = "${env.DEV_HOST}"
                  username = "${env.DEV_USERNAME}"
                  password = "${env.DEV_PASSWORD}"
                  dockerUsername = "${env.DOCKER_USERNAME}"
                  dockerPassword = "${env.DOCKER_PASSWORD}"
              }

              // git last commit setting (for Slack Notification)
              LAST_COMMIT = sh(returnStdout: true, script: "git log -1 --pretty=%B").trim()

              echo '[host] ' + host
              echo '[username] ' + username
              echo '[password] ' + password
              echo '[dockerUsername] ' + dockerUsername
              echo '[dockerPassword] ' + dockerPassword
              echo '[last commit] ' + LAST_COMMIT
          }
        }
      }

      stage('[Dev] Build'){
        when {
          branch 'dev'
        }
        steps {
            script {
                sh './mvnw clean package -P dev'
                // sudo usermod -aG docker jenkins
                // sudo chown jenkins:docker /var/run/docker.sock
                // sudo chmod 660 /var/run/docker.sock
                sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${TODAY} ."
            }
        }
      }

      stage('[Dev] Push to Docker Hub'){
        when {
          branch 'dev'
        }
        steps {
            script {
                sh "docker login -u ${dockerUsername} -p ${dockerPassword}"
                sh "docker push ${DOCKER_IMAGE_NAME}:${TODAY}"
                sh "docker logout"
            }
        }
      }

      stage ('[Dev] Deploy to Server') {
        when {
          branch 'dev'
        }
        steps {
          script {
            def remote = setRemote(host, username, password)

            // ------ use SSH pipeline steps plugin
            sshCommand remote: remote, command: "docker login -u ${dockerUsername} -p ${dockerPassword}"
            sshCommand remote: remote, command: "docker pull ${DOCKER_IMAGE_NAME}:${TODAY}"

            sshCommand remote: remote, command: "docker stop ${DOCKER_CONTAINER_NAME}"
            healthCheck(host, DEV_SERVER_PORT, "stop", 1)

            sshCommand remote: remote, command: "docker rm ${DOCKER_CONTAINER_NAME}"
            sshCommand remote: remote, command: "docker run -it -p ${DEV_SERVER_PORT}:8080 --name ${DOCKER_CONTAINER_NAME} -d ${DOCKER_IMAGE_NAME}:${TODAY}"
            healthCheck(host, DEV_SERVER_PORT, "start", 5)

            sshCommand remote: remote, command: "docker logout"
          }
        }
      }
    }

    // ------ use Slack Notification plugin
    post {
       success {
            slackSend color: "good", message: "✅Build Success!\n\n\n PROJECT             : ${JOB_NAME}\n BRANCH             : ${env.BRANCH_NAME}\n JENKINS URL     : <${env.RUN_DISPLAY_URL}|Blue Ocean Link>\n LAST_COMMIT  : ${LAST_COMMIT}"
       }
       failure {
            slackSend color: "danger", message: "❌Build Fail!\n\n\n PROJECT             : ${JOB_NAME}\n BRANCH             : ${env.BRANCH_NAME}\n JENKINS URL     : <${env.RUN_DISPLAY_URL}|Blue Ocean Link>\n LAST_COMMIT  : ${LAST_COMMIT}"
       }
    }

}

def setRemote(host, username, password) {
    def remote = [:]
    remote.name = host
    remote.host = host
    remote.port = 22
    remote.allowAnyHosts = true
    remote.user = username
    remote.password = password

    return remote
}


def healthCheck(host, port, type, sleepSecond) {
    sleep(sleepSecond)

    try {
      def checkResult = sh(script: "curl ${host}:${port}/healthCheck", returnStdout: true)

      if(checkResult == "Y") {
          if(type == "stop") {
             echo '[service stop] fail'
             sh 'exit 1'
          }
          echo '[service start] success'

      } else {
          throw new RuntimeException();
      }

    } catch (Exception e) {
        if(type == "start") {
            echo '[service start] fail'
            sh 'exit 1'
        }
        echo '[service stop] success'
    }
}
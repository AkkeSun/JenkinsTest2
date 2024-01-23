pipeline {
    agent any

    // environment variable setting
    environment {

      DEV_JAR_NAME = 'JenkinsTest-dev.jar'
      DEV_SERVER_JAR_PATH = '/home/od'
      DEV_JENKINS_SERVER_JAR = '/var/lib/jenkins/workspace/JenkinsTest2_dev/target/JenkinsTest-dev.jar'

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
                  port = "${env.DEV_PORT}"
                  username = "${env.DEV_USERNAME}"
                  password = "${env.DEV_PASSWORD}"
              }

              // git last commit setting (for Slack Notification)
              LAST_COMMIT = sh(returnStdout: true, script: "git log -1 --pretty=%B").trim()

              echo '[host] ' + host + ':' + port
              echo '[username] ' + username
              echo '[password] ' + password
              echo '[last commit] ' + LAST_COMMIT
          }
        }
      }

      stage('[Dev] Build'){
        when {
          branch 'dev'
        }
        steps {
          withMaven(maven: 'maven3.5.4') {
            sh 'mvn clean package -P dev'
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
FROM adoptopenjdk/openjdk11

ARG JAR_FILE=target/JenkinsTest.jar

RUN mkdir /data
RUN mkdir /data/application

# Docker 이미지 내 작업 위치 선언 (미선언시 root에서 작업 수행)
WORKDIR /data/application

# 로컬 서버에 있는 파일을 컨테이너 내부로 복사 (호스트경로 컨테이너경로)
# WORKDIR 를 선언했으므로 /data/application/app.jar
COPY ${JAR_FILE} JenkinsTest.jar

# 호스트와 연결할 컨테이너 포트번호
EXPOSE 8080

# 컨테이너 내의 /data/application/log 데이터를 보관하도록 설정
VOLUME ["log"]

# 컨테이너 시작시 실행할 스크립트 작성
ENTRYPOINT ["java","-jar","/data/application/JenkinsTest.jar"]
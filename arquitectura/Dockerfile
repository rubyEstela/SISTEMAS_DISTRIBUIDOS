FROM openjdk:11
VOLUME /tmp
EXPOSE 8091
ARG JAR_FILE=./arquitectura/target/spring-boot-docker.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]

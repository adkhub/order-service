FROM eclipse-temurin:21-jdk AS build
WORKDIR /home/gradle/project

RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget https://services.gradle.org/distributions/gradle-8.2.1-bin.zip && \
    unzip gradle-8.2.1-bin.zip -d /opt && \
    ln -s /opt/gradle-8.2.1/bin/gradle /usr/bin/gradle && \
    useradd -m gradleuser

USER gradleuser
ENV GRADLE_USER_HOME=/home/gradleuser/.gradle

COPY --chown=gradleuser:gradleuser . .
RUN gradle build -x test

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /home/gradle/project/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

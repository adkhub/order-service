FROM eclipse-temurin:21-jdk AS build
WORKDIR /home/gradleuser/project

RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget https://services.gradle.org/distributions/gradle-8.2.1-bin.zip && \
    unzip gradle-8.2.1-bin.zip -d /opt && \
    ln -s /opt/gradle-8.2.1/bin/gradle /usr/bin/gradle && \
    useradd -m -d /home/gradleuser gradleuser && \
    chmod -R 0777 /home/gradleuser

USER gradleuser
WORKDIR /home/gradleuser/project
ENV GRADLE_USER_HOME=/home/gradleuser/.gradle

COPY --chown=gradleuser:gradleuser . .
RUN chmod -R 0777 /home/gradleuser && gradle build -x test

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /home/gradleuser/project/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

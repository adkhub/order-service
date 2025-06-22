FROM eclipse-temurin:21-jdk AS build
RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget https://services.gradle.org/distributions/gradle-8.2.1-bin.zip && \
    unzip gradle-8.2.1-bin.zip -d /opt && \
    ln -s /opt/gradle-8.2.1/bin/gradle /usr/bin/gradle && \
    useradd -m -d /home/gradleuser gradleuser && \
    mkdir -p /home/gradleuser/project/.gradle && \
    chown -R gradleuser:gradleuser /home/gradleuser

WORKDIR /home/gradleuser/project
ENV HOME=/home/gradleuser
ENV GRADLE_USER_HOME=/home/gradleuser/.gradle

COPY --chown=gradleuser:gradleuser . .

USER root
RUN chmod -R 0777 /home/gradleuser

USER gradleuser

RUN gradle build -x test && ls -l /home/gradleuser/project/build/libs/

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /home/gradleuser/project/build/libs/*.jar app.jar
RUN chmod -R 0777 /app
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

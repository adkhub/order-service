FROM eclipse-temurin:21 AS build
RUN apt-get update && \
    apt-get install -y wget unzip passwd && \
    wget https://services.gradle.org/distributions/gradle-8.2.1-bin.zip && \
    unzip gradle-8.2.1-bin.zip -d /opt && \
    ln -s /opt/gradle-8.2.1/bin/gradle /usr/bin/gradle

WORKDIR /workspace
ENV HOME=/workspace
ENV GRADLE_USER_HOME=/workspace/.gradle

COPY . .

# Run build as root in a root-owned directory, disable daemon, clean before build
RUN gradle --no-daemon clean build -x test && ls -l /workspace/build/libs/

FROM eclipse-temurin:21
WORKDIR /app
COPY --from=build /workspace/build/libs/*.jar app.jar
RUN chmod -R 0777 /app
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD curl -f http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]

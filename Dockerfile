# Build stage (Java 21)
FROM eclipse-temurin:21-jdk-jammy as builder
WORKDIR /app
COPY . .
RUN ./gradlew clean build

# Runtime stage (Lightweight JRE)
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=builder /app/build/libs/order-service-app.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
#Build stage
FROM maven:3.8-eclipse-temurin-17 as builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
Run mvn package

# Use a base image with Java 17
FROM eclipse-temurin:17-jre-alpine as final
WORKDIR /app
COPY --from=builder /app/target/*.jar /app/application.jar
Run export SQS_QUEUE_URL="https:dockerfile derp"
ENTRYPOINT ["java", "-jar", "/app/application.jar"]
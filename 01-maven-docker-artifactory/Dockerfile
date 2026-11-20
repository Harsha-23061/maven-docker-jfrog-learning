# syntax=docker/dockerfile:1
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN --mount=type=secret,id=maven_settings,target=/root/.m2/settings.xml \
    --mount=type=secret,id=jfrog_user \
    --mount=type=secret,id=jfrog_token \
    JFROG_USER="$(cat /run/secrets/jfrog_user)" \
    JFROG_TOKEN="$(cat /run/secrets/jfrog_token)" \
    mvn -B -ntp clean deploy

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
CMD ["java", "-cp", "app.jar", "com.example.Main"]

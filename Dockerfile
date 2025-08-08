# Stage 1: Build JAR
FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy pom.xml first (to cache dependencies)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the source code
COPY src ./src

# Package the application (skip tests for faster builds)
RUN mvn clean package -DskipTests

# Stage 2: Run JAR
FROM eclipse-temurin:11-jdk

WORKDIR /app

# Copy jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Copy your PEM file to /app directory
COPY testasp.pem /app/testasp.pem

EXPOSE 9090

ENV BASE_URL=https://localhost:9090

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

# Stage 1: Build the Java backend with Maven
FROM maven:3.8.6-eclipse-temurin-17 AS backend-build

WORKDIR /app
COPY backend/pom.xml backend/
RUN mvn -f backend/pom.xml clean package

COPY backend/ /app/
RUN mvn package

# Stage 2: Setup Node.js frontend
FROM node:18-alpine AS frontend-build

WORKDIR /app
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Stage 3: Final runtime container
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy backend JAR
COPY --from=backend-build /app/target/*.jar app.jar

# Copy frontend build
COPY --from=frontend-build /app/dist /var/www/html

# Install PostgreSQL client (if needed for migrations)
RUN apt-get update && apt-get install -y postgresql-client

# Expose ports (adjust as needed)
EXPOSE 8080 3000

CMD ["java", "-jar", "app.jar"]


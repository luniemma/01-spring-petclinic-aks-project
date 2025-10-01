FROM gradle:jdk17 AS BUILD

# Set working directory for Gradle
WORKDIR /project

# Copy project files and build
COPY --chown=gradle:gradle . .
RUN gradle clean build

# Use a lighter JDK image for runtime
FROM eclipse-temurin:17-jdk
ENV PORT 8080
EXPOSE 8080

# Copy the built JAR to the runtime image and give it a predictable name
ARG JAR_FILE=/project/build/libs/*.jar
COPY --from=BUILD ${JAR_FILE} /opt/app.jar

# Set working directory
WORKDIR /opt/

# List files in the /opt directory for verification
RUN ls -l

# Run the packaged Spring Boot application
CMD ["java", "-jar", "app.jar"]

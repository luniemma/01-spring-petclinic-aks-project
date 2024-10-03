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

# Copy built JARs to the runtime image
COPY --from=BUILD /project/build/libs/* /opt/

# Set working directory
WORKDIR /opt/

# List files in the /opt directory for verification
RUN ls -l

# Use a specific JAR name in CMD, assuming the built JAR follows the naming convention
CMD ["java", "-jar", "spring-petclinic-1.0.0.jar"]  # Replace <version> with the actual version

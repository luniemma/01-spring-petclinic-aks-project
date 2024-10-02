FROM gradle:jdk17 as BUILD

COPY --chown=gradle:gradle . /project
RUN gradle -i -s -b /project/build.gradle clean build

FROM eclipse-temurin:17-jdk
ENV PORT 8080
EXPOSE 8080

COPY --from=BUILD /project/build/libs/* /opt/
WORKDIR /opt/
RUN ls -l
CMD ["/bin/bash", "-c", "find -type f -name '*SNAPSHOT.jar' | xargs java -jar"]

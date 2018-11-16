#fistStage
FROM node:latest AS storefront
WORKDIR /usr/src/atsea/app/react-app
COPY react-app
RUN npm install
RUN npm run build


#secondStage
WORKDIR /usr/src/atsea
COPY pom.xml
RUN mvn -B -f pom.xml -s /usr/share/maven/ref/setting-docker.xml dependency:resolve
COPY . .
RUN mvn -B -f /usr/share/maven/ref/setting-docker package -DskipTests



#thierdStage
FROM java:8-jdk-alpine AS production
RUN adduser -Dh /home/gordon gordon
COPY --from=storefront /usr/src/atsea/app/react-app/build/ .
WORKDIR /app
COPY --from=addserver /usr/src/atsea/target/AtSea-0.0.1-SNAPSHOT.jar .
ENTRYPOINT ["java", "-jar", "/app/atSea-0.0.1-SNAPSHOT.jar"]
CMD ["--spring.profiles.active=postgres"]

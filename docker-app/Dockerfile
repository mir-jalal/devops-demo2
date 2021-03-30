#!/usr/bin/env bash

####################
## Builder Image

FROM alpine:3.7 AS builder
RUN apk --no-cache add openjdk8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
WORKDIR /src/

COPY /spring-petclinic .

RUN ./mvnw package

#####################
## Build

FROM alpine:3.7

RUN apk --no-cache add openjdk8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

WORKDIR /app/

COPY --from=builder /src/target/spring-petclinic-*.jar ./app.jar

ENV MYSQL_PASS "B*T_ity6"
ENV MYSQL_URL "jdbc:mysql://172.17.0.1:3306/demo2"
ENV MYSQL_USER "demo2"

EXPOSE 8080

CMD ["java", "-jar", "-Dspring.profiles.active=mysql", "app.jar"]

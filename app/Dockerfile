#!/usr/bin/env bash

FROM alpine:3.7

RUN apk --no-cache add openjdk8

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

ADD /target/spring-petclinic-*.jar /petclinic/app/app.jar

WORKDIR /petclinic/app

EXPOSE 8080

CMD ["java", "-jar", "-Dspring.profiles.active=mysql", "app.jar"]

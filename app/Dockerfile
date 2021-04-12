#!/usr/bin/env bash

FROM alpine:3.7

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

WORKDIR /home/petclinic/app

RUN apk --no-cache add openjdk8 && addgroup appgroup && adduser -h /home/petclinic/ -G appgroup -D petclinic

USER petclinic

COPY /target/spring-petclinic-*.jar ./app.jar
COPY *.sh /

EXPOSE 8080

ENTRYPOINT /entrypoint.sh

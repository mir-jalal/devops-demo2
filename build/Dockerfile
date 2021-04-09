#!/usr/bin/env bash

FROM alpine:3.7

RUN apk --no-cache add openjdk8 && apk --no-cache add git
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

RUN git clone https://github.com/mir-jalal/spring-petclinic.git

WORKDIR /spring-petclinic

RUN git checkout $BUILD_BRANCH

CMD ["./mvnw", "package"]


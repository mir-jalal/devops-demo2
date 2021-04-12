#!/usr/bin/env bash

FROM alpine:3.7

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

RUN apk --no-cache add openjdk8 && apk --no-cache add git

COPY *.sh /

RUN /startup.sh

ENTRYPOINT /entrypoint.sh

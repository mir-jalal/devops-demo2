#!/usr/bin/env bash

apt-get -y update

cd /home/demo2 || exit

git clone https://github.com/spring-projects/spring-petclinic.git

cd ./spring-petclinic || exit

chmod +x mvnw

./mvnw clean
./mvnw package



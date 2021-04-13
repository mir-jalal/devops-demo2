cd ./spring-petclinic && git init && \
git remote add origin https://"$GIT_USER":"$GIT_ACCESS_TOKEN"@github.com/mir-jalal/spring-petclinic.git && \
git pull origin "$BUILD_BRANCH" && \
git checkout "$BUILD_BRANCH" && \
./mvnw package

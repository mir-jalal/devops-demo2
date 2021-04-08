# DEVOPS-Demo-2
___

This is Demo-2 task repo for IbaTech Academy

## Subtask I - Application
___

- Set up the repository:
  <pre>
  $ sudo apt-get update
  $ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  </pre>

- Added Docker's official GPG key:
  `$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg`

- Used the following command to set up the stable repo:
  <pre>
  $ echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $ (lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  </pre>

- Installed docker engine
  <pre>
  $ sudo apt-get update
  $ sudo apt-get install docker-ce docker-ce-cli containerd.io
  </pre>

  > To get more detailed documentation you may look at:
  > [Docker - Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

- As it is not possible to mount volume, I used multistage dockerfile to keep image size less and use cache.

  Following part of `Dockerfile` installs openjdk and builds java project with `mvnw` script:
  <pre>
  FROM alpine:3.7 AS builder
  RUN apk --no-cache add openjdk8
  ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
  WORKDIR /src/

  COPY /spring-petclinic .

  RUN ./mvnw package
  </pre>

  Then following part of the Dockerfile puts application jar into separate folder and exposes 8080 port:

  <pre>
  FROM alpine:3.7

  RUN apk --no-cache add openjdk8
  ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

  WORKDIR /app/

  COPY --from=builder /src/target/spring-petclinic-*.jar ./app.jar

  EXPOSE 8080

  CMD ["java", "-jar", "-Dspring.profiles.active=mysql", "app.jar"]
  </pre>

- Following docker command can be used to build and tag an image:

  `docker build -t petclinic-app ./petclinic-app`
  > However, there is ansible playbook in the project that tags all the images and runs containers

- Following docker command can be used to run the container:

  `docker run -d -p 8089:8080 petclinic-app`

## Subtask II - Database
- For the Database container, following variables encrypted with ansible-vault are used in ansible-playbook to create non-root user, password, and database.
  Vault.yml can be created by `ansible-vault create vault.yml`.
  Then, password should be set for it and default editor is used to edit that file.
  > + mysql_user:
  > + mysql_pass:
  > + mysql_root_pass:
  > + mysql_database:

  > Mainly default editor is vim, so good luck with it. You can start to edit file with `INSERT` button. After file is completed, press `ESC` and type `:wq` to save file.
  > Never forget my favor :D

- To save data on host machine, following command is used:
  <pre>
  volumes:
    - {path/to/directory}:/var/lib/mysql
  </pre>

- Following docker command can be used to build and tag an image:

  `docker build -t petclinic-db ./petclinic-db`
  > However, there is ansible playbook in the project that tags all the images and runs containers

- Following docker command can be used to run the container:

  `docker run -d -p 3306:3306 petclinic-db`

## Subtask III - Registry

- Following command can be used to tag image and push them to the registry:

  + Docker tag

    `docker tag {source_image}:{source_tag} {registry_url}:{registry_port}/{target_image}:{target_image_tag}`

    > For my case command was:
    > + `docker tag petclinic-app:latest localhost:5000/petclinic-app:latest`
    >
    >> For more detailed information:
    >> * [Docker - Tag Command](https://docs.docker.com/engine/reference/commandline/tag/)

  + Docker push

    `docker push {registry_url}:{registry_port}/{target_image}:{target_image_tag}`

    > For my case command was:
    > + `docker push localhost:5000/petclinic-app:latest`
    >> For more detailed information:
    >> * [Docker - Push Command](https://docs.docker.com/engine/reference/commandline/push/)

## Subtask IV - Jenkins
- I used `Docker Dind` to create docker environment for Jenkins. So it is isolated from host Docker environment. Following part of `docker-compose` file creates container for `docker:dind` and mounts required volumes to make data persistent.
  <pre>
  dind:
    image: docker:dind
    container_name: jenkins_docker
    privileged: true
    networks:
      jenkins:
        aliases:
          - docker
    environment:
      DOCKER_TLS_CERTDIR: /certs
    volumes:
    - jenkins-docker-certs:/certs/client
    - jenkins-data:/var/jenkins_home
    expose:
      - 2376
    ports:
    - 2376:2376
  </pre>

- Jenkins stores files in `/var/jenkins_home` directory, so I isolated it from host machine. Following part of `docker-compose` file creates Jenkins container and run it:
  <pre>
  jenkins:
    build:
      context: ./
      dockerfile: Dockerfile
    networks:
      - jenkins
    environment:
      DOCKER_HOST: tcp://docker:2376
      DOCKER_CERT_PATH: /certs/client
      DOCKER_TLS_VERIFY: 1
    expose:
      - 8080
      - 50000
    ports:
    - 8080-8099:8080
    - 50000:50000
    volumes:
    - jenkins-data:/var/jenkins_home
    - jenkins-docker-certs:/certs/client:ro
    depends_on:
      - dind
  </pre>

- I also provide the whole `docker-compose.yml` and `Dockerfile` I used:

  `./docker-compose.yml`
  <pre title="docker-compose.yml">
  version: '3.7'
  services:
    dind:
      image: docker:dind
      container_name: jenkins_docker
      privileged: true
      networks:
        jenkins:
          aliases:
            - docker
      environment:
        DOCKER_TLS_CERTDIR: /certs
      volumes:
      - jenkins-docker-certs:/certs/client
      - jenkins-data:/var/jenkins_home
      expose:
        - 2376
      ports:
      - 2376:2376
    jenkins:
      build:
        context: ./
        dockerfile: Dockerfile
      networks:
        - jenkins
      environment:
        DOCKER_HOST: tcp://docker:2376
        DOCKER_CERT_PATH: /certs/client
        DOCKER_TLS_VERIFY: 1
      expose:
        - 8080
        - 50000
      ports:
      - 8080-8099:8080
      - 50000:50000
      volumes:
      - jenkins-data:/var/jenkins_home
      - jenkins-docker-certs:/certs/client:ro
      depends_on:
        - dind
    
  volumes:
    jenkins-data:
      name: jenkins-data
    jenkins-docker-certs:
      name: jenkins-docker-certs

  networks:
    jenkins:
      name: jenkins
  </pre>

  `./Dockerfile`

  <pre>
  FROM jenkins/jenkins:2.277.1-lts-jdk11
  USER root
  RUN apt-get update && apt-get install -y apt-transport-https \
  ca-certificates curl gnupg2 \
  software-properties-common
  RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
  RUN apt-key fingerprint 0EBFCD88
  RUN add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable"
  RUN apt-get update && apt-get install -y docker-ce-cli
  USER jenkins
  RUN jenkins-plugin-cli --plugins blueocean:1.24.4
  </pre>

  > For more detailed information you can check following link:
  > * [Jenkins - Jenkins on Docker](https://www.jenkins.io/doc/book/installing/docker/)
  >
  > You can also find more installation documentation of Jenkins for different machines (OS):
  > * [Jenkins - How to install Jenkins](https://www.jenkins.io/doc/book/installing/)

- I used pipeline with two stage to build docker images and push them to the registry:
    <pre>
    #!/usr/bin/env groovy

    pipeline{
        environment {
            registryDb = {registry_db}
            registryApp = {registry_app}
            registryIp = {registry_ip}:{registry_port}
            registryUrl = "https://$registryIp"
            registryCredentialsId = {credential_id_in_jenkins}
        }

        agent any

        stages{
            stage('Build and Push DB image'){
                steps{
                    script{
                        docker.withRegistry(registryUrl, registryCredentialsId){
                            sh("docker build -t ${registryIp + registryDb + ":$BUILD_NUMBER" + ' ./docker-db '}")
                            sh("docker push ${registryIp + registryDb + ":$BUILD_NUMBER"}")
                        }
                    }
                }
            }

            stage('Build and Push App image'){
                steps{
                    script{
                        docker.withRegistry(registryUrl, registryCredentialsId){
                            sh("docker build -t $registryIp$registryApp:$BUILD_NUMBER ./docker-app ")
                            sh("docker push $registryIp$registryApp:$BUILD_NUMBER")
                        }
                    }
                }
            }
        }
    }
  </pre>

## Additional Tasks
- Own Docker Registry:
  * Create `./data` directory, so you can save your images persistent.
  * Also, you need `./auth` directory to store authentication credentials so unauthorized people can't access you registry.
    + `cd ./auth`
    + `sudo apt install apache2-utils` / You need htpasswd to create credentials
    + `htpasswd -Bc registry.password {username}`
  * To create docker registry container I used following `docker-compose.yml`:
      <pre>
    version: '3'
      services:
          registry:
          image: registry:2
          ports:
          - "5000:5000"
          environment:
            REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
            REGISTRY_AUTH: htpasswd
            REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
            REGISTRY_AUTH_HTPASSWD_PATH: /auth/registry.password
      volumes:
        - ./data:/data
        - ./auth:/auth
    </pre>
  > You can use following links for detailed information:
  > * [Docker - Registry Deploying](https://docs.docker.com/registry/deploying/)
  > * [Digital Ocean - Tutorial for registry](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-18-04)

- Create a job that triggered on changes:
  I used Job DSL syntax to trigger my job with following part of script:
  <pre>
  properties {
        pipelineTriggers {
            triggers {
              gitlab{
                triggerOnPush(true)
              }
            }
        }
  }
  </pre>

  To trigger my job, I also configured my gitlab repo. I added `http://{machine_ip}:{jenkins_port}/project/{job_name}` to webhook urls.
  > There might be several errors during configuration of these settings:
  > * You might need to remove checkbox of `Enable authentication for '/project' end-point` at Jenkins Configuration.

- Setup Jenkins to look for `Jenkinsfile`:
  Following part of the script is used to look for `Jenkinsfile` in gitlab repo:
  <pre>
  definition {
    cpsScm{
      scm{
        git {
          remote{
          	name('origin')
          	url('https://{gitlab_username}:{gitlab_access_token}@{gitlab_ip}/{project_owner}/{project_name}')
          }
        }
        scriptPath("Jenkinsfile")
      }
    }
  }
  </pre>

  > You can find how to get access token from gitlab:
  > * [Gitlab - Access Tokens](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html)

- Describing job using Job DSL syntax:
  I created pipeline with two stages to build my project.

  I provide you full script:

  <pre>
  pipelineJob("build-pipeline-job"){
    properties {
        pipelineTriggers {
            triggers {
              gitlab{
                triggerOnPush(true)
              }
            }
        }
    }

    definition {
      cpsScm{
        scm{
          git {
            remote{
              name('origin')
              url('https://{gitlab_username}:{gitlab_access_key}@{gitlab_ip}/{project_owner}/{project_name}')
            }
          }
          scriptPath("Jenkinsfile")
        }
      }
    }
  }
  </pre>

  > You can find additional information at `https://your.jenkins.installation/plugin/job-dsl/api-viewer/index.html`

### To-Do List

- Subtask I - Application
  * [x] Add `docker` folder and put there all Dockerfiles and docker-related scripts if any, then commit and push them in your Gitlab repo.
  * [x] Install `docker` on your host machine
  * [x] Create `Dockerfile` for application container
  * docker build should:
    * [ ] Clone git project and checkout to branch specified in `$BUILD_BRANCH`
    * [x] Use `.m2` dir from host machine
    * [x] Build java project
    * [x] Put application jar into separate folder
    * [ ] Have a separate non-root user to own the application
    * [x] Expose the 8080 port
    * [x] Tag image as `petclinic-app`
  * [x] on docker run it should start java app and connect to mysql database using credentials that you provide in environment variables.

- Subtask II - Database
  * Create Dockerfile for DB container
    * [ ] Customize the mysql database to accept connections only from your private docker network subnet
    * [x] Create a non-root user and password (ENV $MYSQL_USER and $MYSQL_PASSWORD) in mysql
    * [x] Create a database in mysql (ENV $MYSQL_DATABASE) and grant all privileges for the $MYSQL_USER to access the database
    * [x] Expose default mysql port
    * [x] Mysql should save data on host machine, so that it remains persistent after image rebuild
    * [x] Tag image as `petclinic-db`

- Subtask III - Docker registry
  * [x] Create your own docker registry on Gitlab or [DockerHub](https://hub.docker.com/)
  * [x] Push images there

- Subtask IV - Jenkins
  * [x] Setup Jenkins
  * [x] Deploy Jenkins on Local VM or Docker
  * Setup Jenkins plugins (credentials, git, maven-plugin, github, Gitlab, docker, etc.)
    * [x] Create a 1st Jenkins Job it should build your project, package jar into docker image and deploy that image to a Docker registry.
    * [x] Create a 2nd Jenkins Job it should build Database image and deploy that image to a Docker registry.


- Additional tasks
  * [x] Create your own docker registry on host machine and Push images there
  * [x] Create a job that will be triggered on changes in gitlab repo.
  * [x] Describe Jenkins job using **Job DSL** syntax to create jobs automatically
  * [x] Setup Jenkins jobs to look for `Jenkinsfile` in your project root directory


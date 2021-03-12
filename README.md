# devops-demo2

`sudo docker build -t mirjalalcloud/node-web-app`

`sudo docker run -it -d -p 8080:8080 --name test mirjalalcloud/node-web-app`

### To-Do List

- Subtask I - Application
    * [ ] Add `docker` folder and put there all Dockerfiles and docker-related scripts if any, then commit and push them in your Gitlab repo.
    * [x] Install `docker` on your host machine
    * [x] Create `Dockerfile` for application container
    * docker build should:
        * [x] Clone git project and checkout to branch specified in `$BUILD_BRANCH`
        * [ ] Use `.m2` dir from host machine
        * [x] Build java project
        * [ ] Put application jar into separate folder
        * [x] Have a separate non-root user to own the application
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
    * [ ] Create your own docker registry on Gitlab or [DockerHub](https://hub.docker.com/)
    * [x] Push images there

- Subtask IV - Jenkins
    * [ ] Setup Jenkins
    * [ ] Deploy Jenkins on Local VM or Docker
    * Setup Jenkins plugins (credentials, git, maven-plugin, github, Gitlab, docker, etc.)
        * [ ] Create a 1st Jenkins Job it should build your project, package jar into docker image and deploy that image to a Docker registry.
        * [ ] Create a 2nd Jenkins Job it should build Database image and deploy that image to a Docker registry.


- Additional tasks
    * [x] Create your own docker registry on host machine and Push images there
    * [ ] Create a job that will be triggered on changes in gitlab repo.
    * [ ] Describe Jenkins job using **Job DSL** syntax to create jobs automatically
    * [ ] Setup Jenkins jobs to look for `Jenkinsfile` in your project root directory

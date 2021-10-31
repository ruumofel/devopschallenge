Setup Application Environtment using terraform:
make terraform-init
make terraform-apply

Build Application
make docker-Build
make docker-push

Deployment automation
1. run  docker-compose.yaml

changes on the source:
==Makefile==
create makefile for automation

==run locally==
1.docker-compose.yaml
 -network (webserver) : server-network to app-network
 -context : ./app to .
2.Dockerfile
  COPY composer.jason /var/www to COPY ./app/ /var/www
  DO --> COPY
  locales add \
  useradd www www to www www2

==deployment==
create app.yaml 
create webserver.yaml (execute on terraform-apply)




#variable
docker_registry ?= ruum/interview-assessment
tag ?= dev
image_name ?= $(docker_registry):$(tag)

#terraform
terraform-init:
	terraform init

terraform-apply:
	terraform apply -auto-approve

#Build
docker-build:
	docker build -t $(image_name) .

docker-push:
	docker push $(image_name)

#deployment 
deploy:
	docker-compose -f docker-compose.yaml up -d



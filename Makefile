ROOT_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TERRAFORM = cd terraform && terraform
ANSIBLE = cd ansible && ansible-playbook
DOCKER_IMAGE:=pfragoso/hello-api
APP_VERSION:=latest
REDIS_ENDPOINT:=$(shell cd terraform && terraform output redis_endpoint)
ELB_ENDPOINT:=$(shell cd terraform && terraform output elb_address)

.PHONY: build-docker publish-docker run-local test
build-docker:
ifeq ($(APP_VERSION),latest)
	@docker build --rm --tag ${DOCKER_IMAGE}:latest .
else
	@docker build --rm --tag ${DOCKER_IMAGE}:latest .
	@docker build --rm --tag ${DOCKER_IMAGE}:$(APP_VERSION) .
endif


publish-docker: check-docker-env build-docker
	docker login --username "{$DOCKER_USERNAME}" --password "${DOCKER_PASSWORD}"
ifeq ($(APP_VERSION),latest)
	@docker push ${DOCKER_IMAGE}:latest
else
	@docker push ${DOCKER_IMAGE}:$(APP_VERSION)
	@docker push ${DOCKER_IMAGE}:latest
endif

run-local:
	@cd docker && docker-compose up -d

test:
	cd scripts && ./test_api.sh $(ELB_ENDPOINT):8080

check-docker-env:
	@test -n "$(DOCKER_USER)" || \
	(echo "DOCKER_USER env not set"; exit 1)
	@test -n "$(DOCKER_PASSWORD)" || \
	(echo "DOCKER_PASSWORD env not set"; exit 1)

.PHONY: init plan apply destroy infra deploy

plan: check-aws-env
	@$(TERRAFORM) plan -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}"

apply: check-aws-env plan
	@$(TERRAFORM) apply -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" -auto-approve

destroy: check-aws-env
	@$(TERRAFORM) destroy -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}"

init:  
	@$(TERRAFORM) init -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}"

infra: init apply

deploy:
	@$(ANSIBLE) deploy.yaml -e 'image_version=$(APP_VERSION)' -e 'redis_endpoint=$(REDIS_ENDPOINT)'

create-all: publish-docker infra deploy

check-aws-env: 
	@test -n "$(AWS_ACCESS_KEY_ID)" || \
	(echo "AWS_ACCESS_KEY_ID env not set"; exit 1)
	@test -n "$(AWS_SECRET_ACCESS_KEY)" || \
	(echo "AWS_SECRET_ACCESS_KEY env not set"; exit 1)

name := web-app
dockerfile := .

all: help

.PHONY: help
help: Makefile
	@echo
	@echo " Choose a make command to run"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## build: create ecr repo and build/push image: make build name=my-app dockerfile=../
.PHONY: build
build:
	./build.sh ${name} ${dockerfile}

## infra: deploy infrastructure only: make infra name=my-app
.PHONY: infra
infra:
	sam deploy \
		--template-file stack.yml \
		--stack-name ${name} \
		--resolve-s3 \
		--capabilities CAPABILITY_IAM

## infra-app: deploy infrastructure and build/deploy app: make infra-app name=my-app dockerfile=../
.PHONY: infra-app
infra-app: build
	sam deploy \
		--template-file stack.yml \
		--stack-name ${name} \
		--parameter-overrides ImageUrl=$(shell cat ecr-repo) \
		--resolve-s3 \
		--capabilities CAPABILITY_IAM

## delete: delete entire stack: make delete name=my-app
.PHONY: delete 
delete:
	sam delete --stack-name ${name}; \
	aws ecr delete-repository --force --repository-name ${name}


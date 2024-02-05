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

## deploy: deploy stack: make deploy name=my-app
.PHONY: deploy
deploy:
	sam deploy \
		--template-file stack.yml \
		--stack-name ${name} \
		--resolve-s3 \
		--capabilities CAPABILITY_IAM

## buildanddeploy: build image and deploy it: make buildanddeploy name=my-app dockerfile=../
.PHONY: buildanddeploy
buildanddeploy: build
	sam deploy \
		--template-file stack.yml \
		--stack-name ${name} \
		--parameter-overrides ImageUrl=$(shell cat ecr-repo) \
		--resolve-s3 \
		--capabilities CAPABILITY_IAM

## delete: delete stack: make delete name=my-app
.PHONY: delete 
delete:
	sam delete --stack-name ${name}; \
	aws ecr delete-repository --force --repository-name ${name}

#!/bin/bash
set -e

REPO_NAME=$1
DOCKERFILE=$2

# unique image version/tag
export VERSION=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 50 | head -n 1)

# login to ecr
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com

# create ecr repo (if not exists)
aws ecr describe-repositories --repository-names ${REPO_NAME} || aws ecr create-repository --repository-name ${REPO_NAME}
URI=$(aws ecr describe-repositories --repository-names ${REPO_NAME} | jq '.repositories[0].repositoryUri' -r)

# build and push image
IMAGE=${URI}:${VERSION}
echo ""
echo "building and pushing image: ${IMAGE}"
docker build --platform linux/amd64 -t ${IMAGE} ${DOCKERFILE}
docker push ${IMAGE}
echo ${IMAGE} > ecr-repo

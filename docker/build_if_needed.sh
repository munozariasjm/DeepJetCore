#!/bin/bash

BASE_IMAGE_TAG=cu11.6


if [ $1 ]
then 
FORCE=true
fi

git fetch
if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ] || [ $FORCE ]
then

  COMMIT=$(git log -n 1 --pretty=format:"%H")
  
  echo "building container for commit ${COMMIT}"
  
  OLD_BASE_ID=$(git rev-parse HEAD:docker/Dockerfile_base) 
  git pull
  NEW_BASE_ID=$(git rev-parse HEAD:docker/Dockerfile_base) 
  
  if [ $OLD_BASE_ID != $NEW_BASE_ID ] || [ $FORCE ]
  then
    "base image changed from ${OLD_BASE_ID} to ${NEW_BASE_ID}, rerunning base build"
    docker build --no-cache=true -t cernml4reco/djcbase:$BASE_IMAGE_TAG -f Dockerfile_base .
    docker push --max-concurrent-uploads 3 cernml4reco/djcbase:$BASE_IMAGE_TAG
  fi
  
  docker build --no-cache=true -t cernml4reco/deepjetcore3:latest . \
       --build-arg BUILD_DATE="$(date)" --build-arg BASE_IMAGE_TAG=$BASE_IMAGE_TAG \
       --build-arg COMMIT=$COMMIT 
  docker push --max-concurrent-uploads 3 cernml4reco/deepjetcore3:latest
fi

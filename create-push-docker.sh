#!/bin/bash

set -e

TAG=$(git rev-parse --short HEAD)

echo "Building Docker images"
docker build -t petecheslock/django_app:$TAG -f ./dockerfiles/prod/django/Dockerfile .
docker build -t petecheslock/nginx_app:$TAG -f ./dockerfiles/prod/nginx/Dockerfile .

IMAGE_ID_DJANGO=$(docker images | grep petecheslock/django_app | head -n1 | awk '{print $3}')
IMAGE_ID_NGINX=$(docker images | grep petecheslock/nginx_app | head -n1 | awk '{print $3}')

echo "Tagging latest images"
docker tag $IMAGE_ID_DJANGO petecheslock/django_app:latest
docker tag $IMAGE_ID_NGINX petecheslock/nginx_app:latest

echo "Pushing Docker image"
docker push petecheslock/django_app:$TAG
docker push petecheslock/django_app:latest
docker push petecheslock/nginx_app:$TAG
docker push petecheslock/nginx_app:latest

echo "Done"

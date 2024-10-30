#!/bin/bash

set -e

TAG=$(git rev-parse --short HEAD)

echo "Building Docker images"
docker build -t petecheslock/test_django_app:$TAG -f ./dockerfiles/prod/django/Dockerfile .
docker build -t petecheslock/nginx_app:$TAG -f ./dockerfiles/prod/nginx/Dockerfile .

# Improved Image ID Retrieval
IMAGE_ID_DJANGO=$(docker inspect --format="{{.Id}}" petecheslock/test_django_app:$TAG)
IMAGE_ID_NGINX=$(docker inspect --format="{{.Id}}" petecheslock/nginx_app:$TAG)

# Debugging: Verify Image IDs
echo "DJANGO Image ID: $IMAGE_ID_DJANGO"
echo "NGINX Image ID: $IMAGE_ID_NGINX"

# Error Handling: Check if Image IDs were retrieved
if [ -z "$IMAGE_ID_DJANGO" ] || [ -z "$IMAGE_ID_NGINX" ]; then
    echo "Failed to retrieve image IDs."
    exit 1
fi

echo "Tagging latest images"
docker tag $IMAGE_ID_DJANGO petecheslock/test_django_app:latest
docker tag $IMAGE_ID_NGINX petecheslock/nginx_app:latest

echo "Pushing Docker image"
docker push petecheslock/test_django_app:$TAG
docker push petecheslock/test_django_app:latest
docker push petecheslock/nginx_app:$TAG
docker push petecheslock/nginx_app:latest

echo "Done"

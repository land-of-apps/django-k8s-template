#!/bin/bash

set -e

REPOSITORY_URL="petecheslock"
TAG=$(git rev-parse --short HEAD)

echo "Building Docker images"
docker build -t $REPOSITORY_URL/test_django_oscar:$TAG -f ./dockerfiles/dev/django/Dockerfile .
docker build -t $REPOSITORY_URL/nginx_app:$TAG -f ./dockerfiles/dev/nginx/Dockerfile .

# Improved Image ID Retrieval
IMAGE_ID_DJANGO=$(docker inspect --format="{{.Id}}" $REPOSITORY_URL/test_django_oscar:$TAG)
IMAGE_ID_NGINX=$(docker inspect --format="{{.Id}}" $REPOSITORY_URL/nginx_app:$TAG)

# Debugging: Verify Image IDs
echo "DJANGO Image ID: $IMAGE_ID_DJANGO"
echo "NGINX Image ID: $IMAGE_ID_NGINX"

# Error Handling: Check if Image IDs were retrieved
if [ -z "$IMAGE_ID_DJANGO" ] || [ -z "$IMAGE_ID_NGINX" ]; then
    echo "Failed to retrieve image IDs."
    exit 1
fi

echo "Tagging latest images"
docker tag $IMAGE_ID_DJANGO $REPOSITORY_URL/test_django_oscar:latest
docker tag $IMAGE_ID_NGINX $REPOSITORY_URL/nginx_app:latest

echo "Pushing Docker image"
docker push $REPOSITORY_URL/test_django_oscar:$TAG
docker push $REPOSITORY_URL/test_django_oscar:latest
docker push $REPOSITORY_URL/nginx_app:$TAG
docker push $REPOSITORY_URL/nginx_app:latest

echo "Done"

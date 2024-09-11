#!/bin/bash

# Load variables from .env file
export $(grep -v '^#' .env | xargs)

# Build image
docker build \
    --build-arg USER_ID=${USER_ID} \
    --build-arg GROUP_ID=${GROUP_ID} \
    -f ./Dockerfile.apache \
    -t nexb-env-web .


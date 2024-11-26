#!/bin/bash
# This script uploads the latest image to the public registry
. $(azd env list -o json | jq -r '.[0].DotEnvPath')
echo $SERVICE_APP_IMAGE_NAME
az acr login --name soppublicregistry
docker pull $SERVICE_APP_IMAGE_NAME 
docker tag $SERVICE_APP_IMAGE_NAME soppublicregistry.azurecr.io/sopgenie:latest
docker push soppublicregistry.azurecr.io/sopgenie:latest
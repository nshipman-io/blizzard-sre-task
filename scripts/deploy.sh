#!/usr/bin/env bash

SERVICE_NAME=th3-server-service
LABEL_APP=th3-server
LABEL_VERSION=version
IMAGE_NAME=th3-server
IMAGE_VERSION=$1


CURRENT_VERSION=$(kubectl get service $SERVICE_NAME -o=jsonpath="{.spec.selector.$LABEL_VERSION}")

if [ "$CURRENT_VERSION" == "blue" ]; then
  NEW_VERSION="green"
else
  NEW_VERSION="blue"
fi

DEPLOYMENT_YAML=infra/${NEW_VERSION}-deployment.yaml

# Update the image version in the blue or green deployment manifests
sed -i '' "s|image: $IMAGE_NAME:.*|image: $IMAGE_NAME:$IMAGE_VERSION|g" $DEPLOYMENT_YAML

kubectl apply -f $DEPLOYMENT_YAML

# Update the env variable so the change is reflected in the application at runtime
kubectl set env deployment/$LABEL_APP-$NEW_VERSION APP_VERSION=$IMAGE_VERSION

# Print the new active environment
echo "Updated the $NEW_VERSION environment with updated image version: $IMAGE_VERSION"
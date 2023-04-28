#!/usr/bin/env bash

SERVICE_NAME=th3-server-service
LABEL_APP=th3-server
LABEL_VERSION=version
SERVICE_YAML=infra/service.yaml

CURRENT_VERSION=$(kubectl get service $SERVICE_NAME -o=jsonpath="{.spec.selector.$LABEL_VERSION}")

if [ "$CURRENT_VERSION" == "blue" ]; then
  NEW_VERSION="green"
else
  NEW_VERSION="blue"
fi

# Replace the current version label with the new version in the temporary file using a pipe (|) as delimiter
# Use an empty string as the argument for the -i flag to make it compatible with both GNU and BSD sed
sed -i '' "s|$LABEL_VERSION: $CURRENT_VERSION|$LABEL_VERSION: $NEW_VERSION|g" $SERVICE_YAML


# Apply the updated service definition from the temporary file
kubectl apply -f $SERVICE_YAML

# Print the new active environment
echo "Switched to the $NEW_VERSION environment."
#!/bin/bash

# Variables
suffix=$(cat /proc/sys/kernel/random/uuid | cut -d'-' -f1)
RESOURCE_GROUP_NAME="cavm-rg-$suffix"
LOCATION="centralindia"
TEMPLATE_FILE="template.json"
PARAMETERS_FILE="parametersFile.json"

# Register Resource Provider
for provider in "${provider_list[@]}"; do
    echo "Registering provider: $provider"
    az provider register --namespace "$provider"
	
	status=$(az provider show --namespace "$provider" --query "registrationState" -o tsv)
	while [ "$status" != "Registered" ]; do
		status=$(az provider show --namespace "$provider" --query "registrationState" -o tsv)
	done
done
echo "All providers are registered."

# Check if Resource Group exists
if [ "$(az group exists --name $RESOURCE_GROUP_NAME)" = "false" ]; then
    # Create Resource Group
    az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
    sleep 3
    echo "Resource group $RESOURCE_GROUP_NAME created in $LOCATION"
else
    echo "Resource group $RESOURCE_GROUP_NAME already exists."
fi


# Deploy the UbuntuVM ARM template
az deployment group create \
  --resource-group $RESOURCE_GROUP_NAME \
  --template-file $TEMPLATE_FILE \
  --parameters $PARAMETERS_FILE

# Check the deployment status
if [ $? -eq 0 ]; then
    echo "Deployment succeeded."
else
    echo "Deployment failed."
fi

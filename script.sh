#!/bin/bash

# Variables
suffix=$(cat /proc/sys/kernel/random/uuid | cut -d'-' -f1)
RESOURCE_GROUP_NAME="cavm-rg-$suffix"
LOCATION="centralindia"
TEMPLATE_FILE="template.json"
PARAMETERS_FILE="parametersFile.json"

# Register Resource Provider
provider_list=("Microsoft.Compute" "Microsoft.Storage" "Microsoft.Network")

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
echo "Creating Virtual Machine ..."

az deployment group create \
  --resource-group $RESOURCE_GROUP_NAME \
  --template-file $TEMPLATE_FILE \
  --parameters $PARAMETERS_FILE

# Check the deployment status
if [ $? -eq 0 ]; then
    echo "Deployment succeeded."
    echo "Running Setup Script ..."
    
    az vm extension set \
    --resource-group $RESOURCE_GROUP_NAME \
    --vm-name csvm \
    --name CustomScript \
    --publisher Microsoft.Azure.Extensions \
    --settings '{"fileUris": ["https://raw.githubusercontent.com/pankajcloudthat/case_study_vm/refs/heads/setupvm/setup2.sh"], "commandToExecute": "./setup.sh"}'
else
    echo "Deployment failed."
fi




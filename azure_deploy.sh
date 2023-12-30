#!/bin/bash

az login

#------------------------------
# set variables
#------------------------------
rg_name=fbdataengineeringrg
sa_name=fbdataengineeringsa
container_name=data
kv_name=fbdataengineeringkv
kv_secret_name=fbdataengineeringsakey
app_name=airflow-app
app_secret_name=airflow-app-secret
location=eastus


#------------------------------
# create resource group
#------------------------------
az group create --name $rg_name --location $location


#-------------------------------------------
# create storage acccount and container
#-------------------------------------------
az storage account create --name $sa_name \
    --resource-group $rg_name \
    --location eastus --sku Standard_LRS \
    --kind StorageV2 \
    --hns true \
    --allow-blob-public-access false

az storage container create \
 --name $container_name \
 --account-name $sa_name \
 --auth-mode login


#------------------------------
# get storage account key
#------------------------------
key=$(az storage account keys list -g $rg_name -n $sa_name --query [0].value -o tsv)


#-------------------------------------
# create azure key vault and store key
#-------------------------------------
az keyvault create \
 --resource-group $rg_name \
 --name $kv_name \
 --location $location

az keyvault secret set --vault-name $kv_name --name $kv_secret_name --value $key


#------------------------------------------
# register app and assign akv access policy
#------------------------------------------
clientid=$(az ad app create --display-name $app_name --query appId --output tsv)
clientsecret=$(az ad app credential reset --id $clientid --append --display-name $app_secret_name --years 2 --query password --output tsv)
az ad sp create --id $clientid

subscription_id=$(az account list --query "[?isDefault]".id --output tsv)
tenant_id=$(az account list --query "[?isDefault]".tenantId --output tsv)

sleep 20
az keyvault set-policy --name $kv_name --spn $clientid --secret-permissions get


#-------------------------------------
# set airflow config and env variables
#-------------------------------------
if [[ -n "$kv_name" && -n "$clientid" && 
    -n "$tenant_id" && -n "$clientsecret" && 
    -n "$kv_name" && -n "$kv_secret_name" ]]; then 

    echo "AZURE_TENANT_ID=${tenant_id}" >> .env
    echo "AZURE_CLIENT_ID=${clientid}" >> .env
    echo "AZURE_CLIENT_SECRET=${clientsecret}" >> .env
    echo "AZURE_KEY_VAULT_NAME=${kv_name}" >> .env
    echo "AZURE_STORAGE_ACCOUNT_NAME=${sa_name}" >> .env
    echo "AZURE_STORAGE_CONTAINER_NAME=${container_name}" >> .env
    echo "AZURE_STORAGE_SECRET_NAME=${kv_secret_name}" >> .env
    echo "AIRFLOW__SECRETS__BACKEND=airflow.providers.microsoft.azure.secrets.key_vault.AzureKeyVaultBackend" >> .env
    echo AIRFLOW__SECRETS__BACKEND_KWARGS={\"connections_prefix\": \"airflow-connections\", \"variables_prefix\": \"airflow-variables\", \"vault_url\": \"https://${kv_name}.vault.azure.net/\", \"tenant_id\": \"${tenant_id}\", \"client_id\": \"${clientid}\", \"client_secret\": \"$clientsecret\"}  >> .env
    echo "Azure services deployment succeeded and configurations set"
else
    echo "Azure services deployment failed"
fi






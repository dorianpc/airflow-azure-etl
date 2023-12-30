
# Airflow ETL pipeline to Azure


Overview
========

Simple Airflow ETL pipeline that scrapes data from the web, processes the data, and sends the data to Azure Blob Storage. Azure Key Vault is used as the secrets backend.
Astro CLI is used to build the local development Airflow environment.


# Setup

If you'd like to code along, you'll need

**Prerequisites:**

1. [Docker Desktop >= 18.09](https://docs.docker.com/get-docker/)
2. [Astro CLI](https://docs.astronomer.io/astro/cli/install-cli)
4. [Azure Account](https://azure.microsoft.com/en-us/free)
5. [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)

# Steps

Run the following commands via the terminal. If you are using Windows, use [WSL](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-10#1-overview) to set up Ubuntu and run the following commands via that terminal.

The "make up" command runs a deployment script that deploy the following Azure resources.
1. Resource Group
2. Storage Account
3. Container
4. Azure Key Vault
5. Stores Storage Account Secret
6. Registers Application with Azure Entra
7. Assigns Azure Key Vault Secret Read Policy to Application
8. Saves Azure Environment Variables in .env file used in Airflow 

```bash
git https://github.com/dorianpc/airflow-azure-etl/
cd airflow-azure-etl
```
```bash
# Run Setup Script & Start Airflow 
make up 
```
```bash
# Stop Airflow and cleanup Azure resources
make down
```


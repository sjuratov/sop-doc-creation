# Overview

The frontend streamlit app relies on the infrastructure deployed with azd.

Once infrastructure is available, the key parameters are saved in azd environments .env file.
This file is read by load_dotenv and used in the frontend app.

# Prerequisites

- Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Install [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- On Windows install the (Platform PowerShell)[https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4]. **OBS!** It is MUST be installed - it is NOT a Windows PowerShell.
- Login to your tentnant with Azure CLI `az login`

# Deploy the infrastructure

```sh
azd env set AZURE_LOCATION 'swedencentral'
azd up
```

**OBS!** 'Deploying services (azd deploy)' stage can take up to 10 min.

# ENV Variables

The env variables are read from the azd config file located at:

```.azure/<env_name>/.env```

If azd has not been executed, the application will try to source the standard .env file.

## Azure Speech services

AZURE_SPEECH_KEY
AZURE_SPEECH_REGION

## Azure OpenAI
AZURE_OPENAI_ENDPOINT
AZURE_OPENAI_KEY

# Run

```
cd src/frontend
streamlit run streamlit_app.py
```

echo "Soourcing and setting environment variables"

resourceGroupName=rg-$(azd env get-value AZURE_ENV_NAME)
aoaiAccountName=$(azd env get-value AZURE_OPENAI_ACCOUNT_NAME)
speechAccountName=$(azd env get-value AZURE_SPEECH_ACCOUNT_NAME)

aoaiKey=$(az cognitiveservices account keys list \
  --resource-group "$resourceGroupName" \
  --name "$aoaiAccountName" \
  --query "key1" \
  --output tsv)

speechKey=$(az cognitiveservices account keys list \
  --resource-group "$resourceGroupName" \
  --name "$speechAccountName" \
  --query "key1" \
  --output tsv)

if [ $? -eq 0 ]
then
    azd env set AZURE_OPENAI_KEY $aoaiKey
    azd env set AZURE_SPEECH_KEY $speechKey
fi
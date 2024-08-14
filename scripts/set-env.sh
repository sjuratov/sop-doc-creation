echo "Setting environment variables for OpenAI and Speech services - POSIX"

resourceGroupName=rg-$(azd env get-value AZURE_ENV_NAME)
aoaiAccountName=$(azd env get-value AZURE_OPENAI_ACCOUNT_NAME)
speechAccountName=$(azd env get-value AZURE_SPEECH_ACCOUNT_NAME)

aoaiKey=$(az cognitiveservices account keys list \
  --resource-group "$resourceGroupName" \
  --name "$aoaiAccountName" \
  --query "key1" \
  --output tsv | tr -d '\r')

speechKey=$(az cognitiveservices account keys list \
  --resource-group "$resourceGroupName" \
  --name "$speechAccountName" \
  --query "key1" \
  --output tsv | tr -d '\r' )

if [ $? -eq 0 ]
then
    azd env set AZURE_OPENAI_KEY $aoaiKey
    azd env set AZURE_SPEECH_KEY $speechKey
fi
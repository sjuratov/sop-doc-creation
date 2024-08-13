Write-Host "Setting environment variables for OpenAI and Speech services from PS1"

$azdenv = azd env get-values --output json | ConvertFrom-Json
$resourceGroupName = "rg-"+$azdenv.AZURE_ENV_NAME

$aoaiKey=az cognitiveservices account keys list `
  --resource-group $resourceGroupName `
  --name $azdenv.AZURE_OPENAI_ACCOUNT_NAME `
  --query "key1" `
  --output tsv `

$speechKey=az cognitiveservices account keys list `
  --resource-group $resourceGroupName `
  --name $azdenv.AZURE_SPEECH_ACCOUNT_NAME `
  --query "key1" `
  --output tsv `

if ($? -eq $false) {
    Write-Host "Sourcing Keys failed. Has azd up been run?"
    exit 1
}

azd env set AZURE_OPENAI_KEY $aoaiKey
azd env set AZURE_SPEECH_KEY $speechKey

exit 0
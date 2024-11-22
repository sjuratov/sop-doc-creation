#!/bin/bash
cd ../infra

az bicep build --file main.bicep --stdout \
    | jq 'del(.parameters.environmentNameVar)' \
    | jq '.variables.environmentName = ""' \
    | jq '.variables.principalType = ""' \
    > main.json
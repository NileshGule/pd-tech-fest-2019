Param(
    [parameter(Mandatory = $false)]
    [string]$akvName = "ngAkv"
)

Write-Host "Starting deployment of AKV secrets" -ForegroundColor Yellow

# az keyvault secret `
#     set --vault-name $akvName `
#     --name "RABBITMQ-HOST-NAME" `
#     --value "rabbitmq"

# az keyvault secret `
#     set --vault-name $akvName `
#     --name "RABBITMQ-USER-NAME" `
#     --value "user"

# az keyvault secret `
#     set --vault-name $akvName `
#     --name "RABBITMQ-PASSWORD" `
#     --value "PASSWORD"

az keyvault secret `
    set --vault-name $akvName `
    --name "RABBITMQ-BATCH-SIZE" `
    --value "100"

Write-Host "Deployment of AKV secrets completed successfully" -ForegroundColor Yellow
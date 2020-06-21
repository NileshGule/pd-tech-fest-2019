Write-Host "Provisioning AKS cluster with default parameters" -ForegroundColor Cyan
& ((Split-Path $MyInvocation.InvocationName) + "\initializeAKS.ps1")

Write-Host "Provisioning AKV" -ForegroundColor Cyan
& ((Split-Path $MyInvocation.InvocationName) + "\initialize-AKV.ps1")

Write-Host "Installing RabbitMQ on cluster" -ForegroundColor Cyan
& ((Split-Path $MyInvocation.InvocationName) + "\deployRabbitMQ.ps1")

Write-Host "Installing KEDA on cluster" -ForegroundColor Cyan
& ((Split-Path $MyInvocation.InvocationName) + "\deployKEDA.ps1")

Write-Host "Installing CSI AKV Provider on cluster" -ForegroundColor Cyan
& ((Split-Path $MyInvocation.InvocationName) + "\deploy-CSI-AKV-provider.ps1")

Write-Host "Deploy AKV secrets" -ForegroundColor Cyan
& ((Split-Path $MyInvocation.InvocationName) + "\deploy-AKV-secrets.ps1")

Write-Host "Installing TechTalks application on cluster" -ForegroundColor Cyan
& ((Split-Path $MyInvocation.InvocationName) + "\deployTechTalks-AKS.ps1")

Write-Host "Installing Autoscalar on cluster" -ForegroundColor Cyan
& ((Split-Path $MyInvocation.InvocationName) + "\deployAutoScaler.ps1")
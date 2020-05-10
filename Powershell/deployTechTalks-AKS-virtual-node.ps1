# source common variables
. .\var.ps1

Write-Host "Starting deployment of TechTalks application and services" -ForegroundColor Yellow

Write-Host "Deploying Tech Talks Consumer " -ForegroundColor Yellow
Set-Location $techTalksConsumerRootDirectory
kubectl apply --filename consumer-deployment-virtual-node.yml

Write-Host "Tech talks Consumer service deployed successfully" -ForegroundColor Cyan

Write-Host "Deploying Tech Talks Producer" -ForegroundColor Yellow
Set-Location $techTalksProducerRootDirectory
kubectl apply --recursive --filename .

Write-Host "Tech talks Producer deployed successfully" -ForegroundColor Cyan

Write-Host "All the services related to Tech Talks application have been successfully deployed" -ForegroundColor Cyan

Set-Location ~/projects/pd-tech-fest-2019/Powershell
# source common variables
. .\var.ps1

Write-Host "Starting deployment of ScaledObject and related resources to Kuberentes cluster" -ForegroundColor Yellow

Write-Host "Deploying Tech Talks Consumer Autoscalar" -ForegroundColor Yellow
Set-Location $autoScalarRootDirectory
kubectl apply --recursive --filename .

Write-Host "ScaledObject and related resources deployed successfully" -ForegroundColor Cyan

Set-Location ~/projects/pd-tech-fest-2019/Powershell
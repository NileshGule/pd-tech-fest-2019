# source common variables
. .\var.ps1

Write-Host "Starting deletion of ScaledObject and related resources from Kuberentes cluster" -ForegroundColor Yellow

Write-Host "Deleting Tech Talks Consumer Autoscalar" -ForegroundColor Yellow
Set-Location $autoScalarRootDirectory
kubectl delete --recursive --filename .

Write-Host "ScaledObject and related resources deleted successfully" -ForegroundColor Cyan

Set-Location ~/projects/pd-tech-fest-2019/Powershell
Write-Host "Starting deletion of TechTalks application and services" -ForegroundColor Yellow

# source common variables
. .\var.ps1

Write-Host "Starting deployment of TechTalks application and services" -ForegroundColor Yellow

Write-Host "Deleting Tech Talks Consumer " -ForegroundColor Yellow
Set-Location $techTalksConsumerRootDirectory
# kubectl delete --recursive --filename .
kubectl delete deployment rabbitmq-consumer-deployment

Write-Host "Tech talks Consumer service deleted successfully" -ForegroundColor Cyan

Write-Host "Deleting Tech Talks Producer" -ForegroundColor Yellow
Set-Location $techTalksProducerRootDirectory
kubectl delete --recursive --filename .

Write-Host "Tech talks Producer deleted successfully" -ForegroundColor Cyan

Write-Host "All the services related to Tech Talks application have been successfully deleted" -ForegroundColor Cyan

Set-Location ~/projects/pd-tech-fest-2019/Powershell

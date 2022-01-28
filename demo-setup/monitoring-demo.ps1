Set-Location ~/projects/pd-tech-fest-2019/Powershell

Write-Host "Deploying TechTalks application" -ForegroundColor Green
# deploy all functionalities for Techtalks
.\deployAll.ps1

Write-Host "Deploying EFK stack" -ForegroundColor Green
# deploy Elasticsearch, Fluend, Kibana
.\deployEFK.ps1

Write-Host "Deploying Prometheus stack" -ForegroundColor Green
# install Prometheus using promtheus-kube-stack
Set-Location ~/IdeaProjects/conference-demo/powershell

.\install-prometheus.ps1

Write-Host "Enabling service monitor for conference demo app" -ForegroundColor Green

Set-Location ~/IdeaProjects/conference-demo/k8s

kubectl apply -R -f .

Write-Host "Enabling service monitor for TEchTalks app" -ForegroundColor Green

Set-Location ~/projects/pd-tech-fest-2019/k8s/Prometheus

kubectl apply -R -f .

Write-Host "Port forwarding Kibana" -ForegroundColor Green
# open new tab with port forward to Kibana
wt -w 0 new-tab --title kibana -p "PowerShell Core" kubectl port-forward --namespace default svc/kibana 5601:5601

Write-Host "Port forwarding Grafana" -ForegroundColor Green

wt -w 0 new-tab --title grafana -p "PowerShell Core" kubectl --namespace monitoring port-forward svc/prometheus-grafana 80:80

wt -w 0 new-tab --title watchers -p "PowerShell Core" split-pane -V kgpow; split-pane -V -p "PowerShell Core" kgdepw 



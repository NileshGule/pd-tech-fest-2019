Write-Host "Starting deployment of Elasticsearch using Helm" -ForegroundColor Yellow

helm repo add elastic https://helm.elastic.co

helm repo update

helm install elasticsearch --version 7.13 elastic/elasticsearch

Write-Host "Deployment of Elasticsearch using Helm completed successfully" -ForegroundColor Yellow

Write-Host "Starting deployment of Fluent-bit using Helm" -ForegroundColor Yellow

helm repo add fluent https://fluent.github.io/helm-charts

helm install fluent-bit fluent/fluent-bit `
--values ../k8s/EFK/fluentbit-deamonset.yaml

Write-Host "Deployment of Fluent-bit using Helm completed successfully" -ForegroundColor Yellow
# kubectl apply -f https://github.com/fluent/fluentd-kubernetes-daemonset/blob/master/fluentd-daemonset-elasticsearch.yaml

Write-Host "Starting deployment of Kibana using Helm" -ForegroundColor Yellow

helm install kibana `
    --set elasticsearch.hosts[0]=elasticsearch-master `
    --set elasticsearch.port=9200 `
    --version 7.2.5 `
    bitnami/kibana 

Write-Host "Deployment of Kibana using Helm completed successfully" -ForegroundColor Yellow
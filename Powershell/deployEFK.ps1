Write-Host "Starting deployment of Elasticsearch using Helm" -ForegroundColor Yellow

# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo add stable https://charts.helm.sh/stable
helm repo add elastic https://helm.elastic.co

helm repo update

helm install elasticsearch --version 7.13 elastic/elasticsearch

# helm upgrade --install efk `
#     --set global.kibanaEnabled=true `
#     bitnami/elasticsearch
    
Write-Host "Deployment of Elasticsearch using Helm completed successfully" -ForegroundColor Yellow

Write-Host "Starting deployment of Fluent-bit using Helm" -ForegroundColor Yellow

# helm upgrade --install fluentd `
#     bitnami/fluentd

helm repo add fluent https://fluent.github.io/helm-charts

helm install fluent-bit fluent/fluent-bit `
--values ../k8s/EFK/fluentbit-deamonset.yaml

# helm install fluent-bit fluent/fluent-bit `
#     --values fluentbit-deamonset.yaml

Write-Host "Deployment of Fluent-bit using Helm completed successfully" -ForegroundColor Yellow

#kubectl port-forward --namespace default svc/efk-coordinating-only 9200:9200
#kubectl get all -l "app.kubernetes.io/name=fluentd,app.kubernetes.io/instance=fluentd"
# kubectl port-forward --namespace default svc/efk-kibana 5601:5601

# kubectl apply -f https://github.com/fluent/fluentd-kubernetes-daemonset/blob/master/fluentd-daemonset-elasticsearch.yaml

Write-Host "Starting deployment of Kibana using Helm" -ForegroundColor Yellow

helm install kibana `
    --set elasticsearch.hosts[0]=elasticsearch-master `
    --set elasticsearch.port=9200 `
    bitnami/kibana 

Write-Host "Deployment of Kibana using Helm completed successfully" -ForegroundColor Yellow
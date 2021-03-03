helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm repo list

helm show values prometheus-community/prometheus

helm show values prometheus-community/prometheus > prometehus-values.yaml

helm install prometheus prometheus-community/prometheus --values ${CAMINHO DO VALUES DO PROMETHEUS}

helm list

helm uninstall $NOme_Release

#Grafana
https://artifacthub.io/packages/helm/kube-ops/grafana
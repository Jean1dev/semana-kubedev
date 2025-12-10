#cria o cluster
k3d cluster create

k3d cluster list

k3d cluster delete ${NOME_CLUSTER}

k3d cluster create binno --servers 1 --agents 2 -p "8080:30000@loadbalancer" -p "8181:30001@loadbalancer" -p "8282:30002@loadbalancer" -p "8383:30003@loadbalancer"

# Alternativa se a porta 8080 estiver em uso:
# k3d cluster create binno --servers 1 --agents 2 -p "9080:30000@loadbalancer" -p "9181:30001@loadbalancer" -p "9282:30002@loadbalancer" -p "9383:30003@loadbalancer"

kubectl get nodes

kubectl get pods

kubectl get services

kubectl create -f ${PATH DO ARQUIVO}

#verificar se tem appmetrics  39min
kubectl top nodes
kubectl top pods